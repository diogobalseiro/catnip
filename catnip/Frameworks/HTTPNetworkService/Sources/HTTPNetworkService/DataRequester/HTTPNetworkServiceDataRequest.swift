//
//  HTTPNetworkServiceDataRequest.swift
//  HTTPNetworkService
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

/// Abstraction representing the conversion of an url request into data
public protocol HTTPNetworkServiceDataRequestProtocol: Sendable {
    
    func requestData(for request: URLRequest) async throws -> Data
}

/// Enum representing the possible errors thrown by the HTTPNetworkServiceDataRequestProtocol
public enum HTTPNetworkServiceDataRequestProtocolError: Swift.Error, Equatable, CustomDebugStringConvertible {

    case badServer(Data, HTTPURLResponse) // Connected to the server but it is not available
    case badClient(Data, HTTPURLResponse) // Connected to the server but our request was invalid
    case badNetwork(NSError) // Could not connect to the server
    case invalidResponse(Data, URLResponse) // Connected to the server but received an invalid response

    public var debugDescription: String {

        switch self {

        case let .badServer(_, response):
            "Error: Bad server => \(response.statusCode)"

        case let .badClient(_, response):
            "Error: Bad client => \(response.statusCode)"

        case let .badNetwork(error):
            "Error: Could not connect at all => \(error.code)"

        case let .invalidResponse(_, response):
            "Error: Received unexpected response => \(response.description)"
        }
    }
}

/// Conformance for URLSession
extension URLSession: HTTPNetworkServiceDataRequestProtocol {
    
    public func requestData(for request: URLRequest) async throws -> Data {
        
        try await processDataPair(try await dataPair(for: request))
    }
}

private extension URLSession {
    private typealias DataPair = (data: Data, response: URLResponse)
    
    /// Converts an url request into a pair of Data and URLResponse. Throws an error if this pair is not available
    /// - Parameter request: The url request
    /// - Returns: The pair of data
    private func dataPair(for request: URLRequest) async throws -> DataPair {
        
        do {
            
            return try await data(for: request)
            
        } catch {
            
            if let protocolError = error as? HTTPNetworkServiceDataRequestProtocolError {
                
                throw protocolError
            }
            
            throw HTTPNetworkServiceDataRequestProtocolError.badNetwork(error as NSError)
        }
    }
    
    /// Processes the pair of data and throws errors if it doesnt contain the expected data
    /// - Parameter dataPair: The data pair
    /// - Returns: The data, properly validated
    private func processDataPair(_ dataPair: DataPair) async throws -> Data {
        
        guard let httpResponse = dataPair.response as? HTTPURLResponse else {
            
            throw HTTPNetworkServiceDataRequestProtocolError.invalidResponse(dataPair.data, dataPair.response)
        }
        
        switch httpResponse.statusCode {
        case 400...499:
            throw HTTPNetworkServiceDataRequestProtocolError.badClient(dataPair.data, httpResponse)

        case 500...599:
            throw HTTPNetworkServiceDataRequestProtocolError.badServer(dataPair.data, httpResponse)

        default:
            break
        }
        
        return dataPair.data
    }
}
