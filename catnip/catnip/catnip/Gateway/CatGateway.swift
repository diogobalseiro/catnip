//
//  CatGateway.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Foundation
import SwiftData
import CatsKitDomain
import os

typealias CatGatewayProtocol = CatGatewayInteractableProtocol & CatGatewayModelContainerProtocol

@MainActor
protocol CatGatewayInteractableProtocol {

    func breeds(offset: Int, limit: Int) async throws -> [CatBreed]
    func searchBreeds(query: String) async throws -> [CatBreed]
    func allFavoriteBreeds() throws -> [CatBreed]

    @discardableResult
    func favoriteBreed(_ breed: CatBreed, favoritedAt: Date) throws -> CatBreed
    
    @discardableResult
    func unfavoriteBreed(_ breed: CatBreed) throws -> CatBreed
}

protocol CatGatewayModelContainerProtocol {

    var modelContainer: ModelContainer { get }
}

protocol PaginationProtocol {

    var page: Int { get }
    var limit: Int { get }
}

enum CatGatewayError: Error {

    case specificBreedNotFound(String)
}

final class CatGateway: CatGatewayModelContainerProtocol {

    private let isStoredInMemoryOnly: Bool

    @MainActor
    private let modelContext: ModelContext
    let modelContainer: ModelContainer

    private let breedsUseCase: CatBreedsUseCase
    private let breedsSearchUseCase: CatBreedsSearchUseCase

    private let reachability: ReachabilityProtocol

    init(isStoredInMemoryOnly: Bool = false,
         breedsUseCase: CatBreedsUseCase,
         breedsSearchUseCase: CatBreedsSearchUseCase,
         reachability: ReachabilityProtocol) {

        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        self.breedsUseCase = breedsUseCase
        self.breedsSearchUseCase = breedsSearchUseCase
        self.reachability = reachability

        let modelContainer = Self.generatedModelContainer(isStoredInMemoryOnly: isStoredInMemoryOnly)
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }
}

private extension CatGateway {

    static func generatedModelContainer(isStoredInMemoryOnly: Bool) -> ModelContainer {

        let schema = Schema([
            CatBreedManagedModel.self,
            PaginationMetadataManagedModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: isStoredInMemoryOnly)

        do {

            return try ModelContainer(for: schema, configurations: [modelConfiguration])

        } catch {

            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

@MainActor
extension CatGateway: CatGatewayInteractableProtocol {

    func breeds(offset: Int, limit: Int) async throws -> [CatBreed] {

        Logger.shared.debug("💾 About to fetch breeds from the database (offset: \(offset), limit: \(limit))")
        let batch = try modelContext
            .fetch(Descriptors.fetchBreeds(offset: offset, limit: limit))
        Logger.shared.debug("💾 Fetched breeds from the database, amount: \(batch.count)")

        // if not enough models exist and we can fetch from the API, lets try that
        if batch.count < limit && reachability.isConnected {

            let pagination = try currentPagination()
            Logger.shared.debug("💾 Fetched pagination from the database, pagination: (page:\(pagination.page), limit: \(pagination.limit))")

            Logger.shared.debug("💾 About to fetch breeds from the API, pagination: (page:\(pagination.page + 1), limit: \(pagination.limit))")

            // Fetch from the API. No need to explicetely jump to a background task or actor because:
            // 1. The api service uses URLSession.shared, which already jumps internally off main-thread
            // 2. This await suspention point allows the main actor to continue executing other code
            // 3. The crud operations are lightweight
            let freshModels = try await breedsUseCase.execute(limit: String(pagination.limit),
                                                              page: String(pagination.page + 1))

            Logger.shared.debug("💾 Fetched fresh models from the API, amount: \(freshModels.count), about to insert")

            if freshModels.isEmpty == false {

                // Add to the databse. Stay in main actor to ensure database correctness
                try insert(freshModels)

                Logger.shared.debug("💾 Inserted fresh models, will bump pagination")

                // Bump pagination
                pagination.page += 1
                try? modelContext.save()
            }

            Logger.shared.debug("💾 About to refetch breeds from the database (offset: \(offset), limit:\(limit)")
            // Retry fetching the database
            let finalBatch = try modelContext
                .fetch(Descriptors.fetchBreeds(offset: offset, limit: limit))

            Logger.shared.debug("💾 Return batch, amount \(finalBatch.count)")
            // Return however many are possible
            return finalBatch.map { $0.toDomain() }

        } else {

            Logger.shared.debug("💾 Batch is either good enough or we can't fetch more")
            // Either enough or nothing more we can do about it
            return batch.map { $0.toDomain() }
        }
    }

    func searchBreeds(query: String) async throws -> [CatBreed] {

        if reachability.isConnected {

            Logger.shared.debug("💾 Connection is up, querying API for query '\(query)'")

            let favoritesById = Dictionary(uniqueKeysWithValues: try allFavoriteBreeds().map { ($0.id, $0) })
            let queryModels = try await breedsSearchUseCase.execute(query: query)

            if queryModels.isEmpty == false {

                // Add to the databse
                try insert(queryModels)

                Logger.shared.debug("💾 Inserted fresh models")

                try? modelContext.save()
            }

            Logger.shared.debug("💾 Hydrate models with their favorite status")

            // Hydrate their current favorite status, if it exists
            let hydratedQueryModels = queryModels.map {

                CatBreed.make(from: $0, favorited: favoritesById[$0.id]?.favorited)
            }

            Logger.shared.debug("💾 Search results are ready")
            return hydratedQueryModels

        } else {

            Logger.shared.debug("💾 Connection is down, querying local db for query '\(query)'")

            return try modelContext
                .fetch(Descriptors.fetchBreeds(query: query))
                .map { $0.toDomain() }
        }
    }

    func allFavoriteBreeds() throws -> [CatBreed] {

        return try modelContext
            .fetch(Descriptors.fetchAllFavorites())
            .map { $0.toDomain() }
    }

    @discardableResult
    func favoriteBreed(_ breed: CatBreed, favoritedAt: Date) throws -> CatBreed {

        guard let managedModel = try modelContext.fetch(Descriptors.fetchBreeds(ids: Set([breed.id]))).first else {

            throw CatGatewayError.specificBreedNotFound(breed.id)
        }

        managedModel.favorited = favoritedAt
        try? modelContext.save()

        return managedModel.toDomain()
    }

    @discardableResult
    func unfavoriteBreed(_ breed: CatBreed) throws -> CatBreed {

        guard let managedModel = try modelContext.fetch(Descriptors.fetchBreeds(ids: Set([breed.id]))).first else {

            throw CatGatewayError.specificBreedNotFound(breed.id)
        }

        managedModel.favorited = nil
        try? modelContext.save()

        return managedModel.toDomain()
    }
}

extension CatGateway {

    func currentPagination() throws -> PaginationMetadataManagedModel {

        guard let pagination = try modelContext
            .fetch(Descriptors.fetchPaginationMetadata()).first else {

            let limit = isStoredInMemoryOnly ? 10 : 40
            let newPagination = PaginationMetadataManagedModel(page: -1, limit: limit)
            modelContext.insert(newPagination)
            try? modelContext.save()

            return newPagination
        }

        return pagination
    }

    func insert(_ prospectiveBreeds: [CatBreed]) throws {

        let prospectiveBreedsIds = Set(prospectiveBreeds.map { $0.id })
        let existingBreeds = try modelContext.fetch(Descriptors.fetchBreeds(ids: prospectiveBreedsIds))
        let existingBreedsIds = Set(existingBreeds.map { $0.id })

        prospectiveBreeds
        /// Filter for duplicate cats
            .filter { existingBreedsIds.contains($0.id) == false }
        /// Create the new managed model
            .map { CatBreedManagedModel.makeReadyForInsertion($0) }
        /// Insert one by one
            .forEach { modelContext.insert($0) }

        /// Save once
        try? modelContext.save()
    }
    
    func clear() throws {
        
        try modelContext.delete(model: CatBreedManagedModel.self)
        try modelContext.delete(model: PaginationMetadataManagedModel.self)
        try modelContext.save()
    }
}

private extension CatGateway {

    struct Descriptors {

        static func fetchPaginationMetadata() -> FetchDescriptor<PaginationMetadataManagedModel> {

            FetchDescriptor<PaginationMetadataManagedModel>()
        }

        static func fetchBreeds(ids: Set<String>) -> FetchDescriptor<CatBreedManagedModel> {

            FetchDescriptor<CatBreedManagedModel>(
                predicate: #Predicate { ids.contains($0.id) }
            )
        }

        static func fetchBreeds(offset: Int, limit: Int) -> FetchDescriptor<CatBreedManagedModel> {

            var descriptor = FetchDescriptor<CatBreedManagedModel>(
                sortBy: [SortDescriptor(\.createdAt)])
            descriptor.fetchLimit = limit
            descriptor.fetchOffset = offset

            return descriptor
        }

        static func fetchBreeds(query: String) -> FetchDescriptor<CatBreedManagedModel> {

            FetchDescriptor<CatBreedManagedModel>(
                predicate: #Predicate { $0.name.localizedStandardContains(query) },
                sortBy: [SortDescriptor(\.favorited, order: .reverse)])
        }

        static func fetchAllFavorites() -> FetchDescriptor<CatBreedManagedModel> {

            FetchDescriptor<CatBreedManagedModel>(
                predicate: #Predicate { $0.favorited != nil },
                sortBy: [SortDescriptor(\.favorited, order: .reverse)])
        }
    }
}

