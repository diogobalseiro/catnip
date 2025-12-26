//
//  CatBreedsSearchUseCase.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

/// UI ready made protocol for searching cat breeds
public protocol CatBreedsSearchUseCaseProtocol {

    func execute(query: String) async throws -> [CatBreed]
}

/// Implementation for the CatBreedsSearchUseCaseProtocol
public struct CatBreedsSearchUseCase: CatBreedsSearchUseCaseProtocol, Sendable {

    private let repository: CatBreedsSearchRepositoryProtocol

    public init(repository: CatBreedsSearchRepositoryProtocol) {

        self.repository = repository
    }

    public func execute(query: String) async throws -> [CatBreed] {

        try await repository.searchBreeds(query: query)
    }
}
