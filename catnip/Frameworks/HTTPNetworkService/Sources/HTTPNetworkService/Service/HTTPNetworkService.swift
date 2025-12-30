//
//  HTTPNetworkService.swift
//  HTTPNetworkService
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

/// Abstraction representing the conversion of an url request into a model
public protocol HTTPNetworkServiceProtocol: Sendable {
    
    func perform<T: Decodable>(_ urlRequest: URLRequest) async throws -> T
}

/// Convenience class that implements HTTPNetworkServiceProtocol
public final class HTTPNetworkService: HTTPNetworkServiceProtocol, Sendable {
        
    public let dataRequester: HTTPNetworkServiceDataRequestProtocol
    private let decoder: JSONDecoder
    
    public init(dataRequester: HTTPNetworkServiceDataRequestProtocol = URLSession.shared,
                decoder: JSONDecoder = JSONDecoder()) {
        
        self.dataRequester = dataRequester
        self.decoder = decoder
    }
    
    /// Conformance for HTTPNetworkServiceProtocol. Throws errors if encoding isn't possible
    /// - Parameter urlRequest: The url request
    /// - Returns: The expected coded model
    public func perform<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {

        try await decoder.decode(T.self,
                                 from: dataRequester.requestData(for: urlRequest))
    }
}
