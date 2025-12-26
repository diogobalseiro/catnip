//
//  CatBreedsSearchRepositoryProtocol.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

/// Abstraction that represents requesting cat breeds
public protocol CatBreedsSearchRepositoryProtocol: Sendable {

    func searchBreeds(query: String) async throws -> [CatBreed]
}
