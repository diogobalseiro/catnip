//
//  Service.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import HTTPNetworkService
import CatsKitDomain

/// Abstraction for requesting cat breeds from the Cats API
public protocol ServiceProtocol: Sendable {

    func breeds(limit: String,
                page: String) async throws -> [CatBreedDTO]

    func searchBreeds(query: String) async throws -> [CatBreedDTO]
}

/// The implementation of the ServiceProtocol
public final class Service: ServiceProtocol {

    public struct Config: Sendable {

        let baseURL: String
        let apiKey: String?
        let timeout: TimeInterval

        public init(baseURL: String,
                    apiKey: String?,
                    timeout: TimeInterval = 60.0) {

            self.baseURL = baseURL
            self.apiKey = apiKey
            self.timeout = timeout
        }
    }

    public enum Error: Swift.Error {

        case invalidURL
    }

    public let config: Config
    let networkService: HTTPNetworkServiceProtocol

    public init(config: Config,
                networkService: HTTPNetworkServiceProtocol = HTTPNetworkService()) {

        self.config = config
        self.networkService = networkService
    }

    public func breeds(limit: String,
                       page: String) async throws -> [CatBreedDTO] {

        try await networkService
            .perform(ServiceEndpoint.breeds(limit: limit, page: page)
                .urlRequest(config: config))
    }

    public func searchBreeds(query: String) async throws -> [CatBreedDTO] {

        try await networkService
            .perform(ServiceEndpoint.searchBreeds(query: query)
                .urlRequest(config: config))
    }
}
