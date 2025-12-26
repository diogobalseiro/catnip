//
//  CatBreedsSearchRepository.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import HTTPNetworkService
import CatsKitDomain

/// Repository model for requesting cat breeds
public final class CatBreedsSearchRepository: CatBreedsSearchRepositoryProtocol, Sendable {

    private let apiService: ServiceProtocol

    public init(apiService: ServiceProtocol) {

        self.apiService = apiService
    }

    public func searchBreeds(query: String) async throws -> [CatBreed] {

        let breedsDTOs = try await apiService.searchBreeds(query: query)
        let mapped = breedsDTOs.map { $0.toDomain() }
        return mapped
    }
}
