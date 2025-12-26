//
//  ServiceEndpoint.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import CatsKitDomain
import HTTPNetworkService

/// An enum that represents the API's endpoints
public enum ServiceEndpoint {
    
    case breeds(limit: String, page: String)
    case searchBreeds(query: String)

    var path: String {
        
        switch self {
        case .breeds:
            "/breeds"
        case .searchBreeds:
            "/breeds/search"
        }
    }
    
    var httpMethod: URLRequest.Method {
        
        switch self {
        case .breeds,
                .searchBreeds:
                .get
        }
    }
    
    var queryParameters: [URLQueryItem] {
        
        switch self {
        case let .breeds(limit, page):
            [
                URLQueryItem(name: Constants.limitKey, value: limit),
                URLQueryItem(name: Constants.pageKey, value: page)
            ]
        case let .searchBreeds(query):
            [
                URLQueryItem(name: Constants.queryKey, value: query)
            ]
        }
    }

    public func urlRequest(config: Service.Config) throws -> URLRequest {
        
        var additionalHeaders: [String: String] = [
            Constants.ContentTypeHeaderKey: Constants.ContentTypeHeaderValue
        ]

        if let apiKey = config.apiKey {

            additionalHeaders[Constants.ApiKeyHeaderKey] = apiKey
        }
        
        return try URLRequest(baseURL: config.baseURL + path,
                              method: httpMethod,
                              additionalHeaders: additionalHeaders,
                              queryParameters: queryParameters,
                              body: nil,
                              timeout: config.timeout)
    }
}

private extension ServiceEndpoint {
    
    enum Constants {

        static let ApiKeyHeaderKey = "x-api-key"
        static let ContentTypeHeaderKey = "Content-Type"
        static let ContentTypeHeaderValue = "application/json"

        static let limitKey = "limit"
        static let pageKey = "page"
        static let queryKey = "q"
    }
}
