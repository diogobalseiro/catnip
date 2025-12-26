//
//  HTTPNetworkServiceDataRequestMock.swift
//  HTTPNetworkService
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import HTTPNetworkService

/// Convencience mock object, conforming to HTTPNetworkServiceDataRequestProtocol, for easy testing and staging
public final class HTTPNetworkServiceDataRequestMock {
    
    public enum Error: Swift.Error {
        
        case mockDataNotFound
    }
    
    let datas: [String: Data]
    let delay: Duration?

    public init(datas: [String: Data] = [String: Data](),
                delay: Duration? = nil) {

        self.datas = datas
        self.delay = delay
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
