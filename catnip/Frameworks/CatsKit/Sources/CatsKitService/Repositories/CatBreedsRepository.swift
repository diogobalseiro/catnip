//
//  CatBreedsRepository.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import HTTPNetworkService
import CatsKitDomain

/// Repository model for requesting cat breeds
public final class CatBreedsRepository: CatBreedsRepositoryProtocol, Sendable {

    private let apiService: ServiceProtocol

    public init(apiService: ServiceProtocol) {

        self.apiService = apiService
    }

    public func breeds(limit: String,
                       page: String) async throws -> [CatBreed] {

        let breedsDTOs = try await apiService.breeds(limit: limit, page: page)
        let mapped = breedsDTOs.map { $0.toDomain() }
        return mapped
    }
}
