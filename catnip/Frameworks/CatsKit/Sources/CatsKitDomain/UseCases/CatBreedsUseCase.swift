//
//  CatBreedsUseCase.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

/// UI ready made protocol for requesting cat breeds
public protocol CatBreedsUseCaseProtocol {

    func execute(limit: String,
                 page: String) async throws -> [CatBreed]
}

/// Implementation for the CatBreedUseCaseProtocol
public struct CatBreedsUseCase: CatBreedsUseCaseProtocol, Sendable {

    private let repository: CatBreedsRepositoryProtocol

    public init(repository: CatBreedsRepositoryProtocol) {

        self.repository = repository
    }
    
    public func execute(limit: String,
                        page: String) async throws -> [CatBreed] {

        try await repository.breeds(limit: limit, page: page)
    }
}
