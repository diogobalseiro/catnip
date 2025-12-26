//
//  URLSessionMock.swift
//  HTTPNetworkService
//
//  Created by Diogo Balseiro on 26/12/2025.
//


import Foundation

/// Mock for the URLSession singleton
final class URLSessionMock: URLProtocol {

    nonisolated(unsafe) static var requestHandler: ((URLRequest) -> (HTTPURLResponse, Data)?)?

    override class func canInit(with request: URLRequest) -> Bool {

        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        
        request
    }
    
    override func startLoading() {
        
        guard let handler = URLSessionMock.requestHandler else {
            
            fatalError("RequestHandler not ready")
        }
        
        guard let (response, data) = handler(request) else {
            
            client?.urlProtocol(self, didFailWithError: NSError(domain: "No Response or data", code: -999))
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
