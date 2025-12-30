//
//  HTTPNetworkServiceDataRequestMock.swift
//  HTTPNetworkService
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import HTTPNetworkService

/// Convencience mock object, conforming to HTTPNetworkServiceDataRequestProtocol, for easy testing and staging
public actor HTTPNetworkServiceDataRequestMock {
    
    public enum Error: Swift.Error {
        
        case mockDataNotFound
    }
    
    public var datas: [String: Data]
    public var delay: Duration?

    public init(datas: [String: Data] = [String: Data](),
                delay: Duration? = nil) {

        self.datas = datas
        self.delay = delay
    }
    
    public func updateData(_ data: Data,
                           for url: String) {
        
        datas[url] = data
    }
}

extension HTTPNetworkServiceDataRequestMock: HTTPNetworkServiceDataRequestProtocol {
    
    public func requestData(for request: URLRequest) async throws -> Data {

        if let delay {

            try await Task.sleep(for: delay)
        }

        guard let url = request.url,
              let data = datas[url.absoluteString] else {
            
            throw Error.mockDataNotFound
        }
        
        return data
    }
}
