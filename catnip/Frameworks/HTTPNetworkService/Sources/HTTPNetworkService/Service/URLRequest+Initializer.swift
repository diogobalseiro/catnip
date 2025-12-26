//
//  URLRequest+Initializer.swift
//  HTTPNetworkService
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

public extension URLRequest {
    
    /// Classic HTTP verbs
    enum Method: String {
        
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
    
    /// Possible errors when constructing an url request
    enum Error: Swift.Error {
        
        case invalidURL
    }
    
    init(baseURL: String,
         method: Method = .get,
         additionalHeaders: [String : String] = [:],
         queryParameters: [URLQueryItem] = [],
         body: Data? = nil,
         timeout: TimeInterval = 60) throws {
        
        guard var url = URL(string: baseURL) else {
            
            throw Error.invalidURL
        }
        
        if queryParameters.isEmpty == false {
            
            url.append(queryItems: queryParameters)
        }
        
        self.init(url: url)

        self.httpMethod = method.rawValue
        self.allHTTPHeaderFields = additionalHeaders
        self.httpBody = body
        self.timeoutInterval = timeout
    }
}
