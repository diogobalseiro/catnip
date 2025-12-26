//
//  CatBreedsRepositoryProtocol.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

/// Abstraction that represents requesting cat breeds
public protocol CatBreedsRepositoryProtocol: Sendable {
    
    func breeds(limit: String,
                page: String) async throws -> [CatBreed]
}
