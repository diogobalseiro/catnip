//
//  HTTPNetworkServiceTests.swift
//  HTTPNetworkService
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import Testing
@testable import HTTPNetworkService
import HTTPNetworkServiceStaging

@Suite("HTTPNetworkServiceTests")
struct HTTPNetworkServiceTests {
    
    struct TestModel: Codable, Equatable {
        
        let id: Int
        let name: String
    }
    
    struct ComplexTestModel: Codable, Equatable {
        
        let id: Int
        let name: String
        let metadata: [String: String]
        let createdAt: Date
        let isActive: Bool
    }
    
    @Test("Simple decoding")
    func testSuccessfulSimpleDecode() async throws {
        
        let testModel = TestModel(id: 1,
                                  name: "Test")
        let data = try JSONEncoder().encode(testModel)
        
        let requestMock = HTTPNetworkServiceDataRequestMock(datas: [
            "https://example.com/1": data
        ])
        let service = HTTPNetworkService(dataRequester: requestMock)
        
        let decoded: TestModel = try await service.perform(.init(baseURL: "https://example.com/1"))
        #expect(decoded == testModel)
    }
    
    @Test("Complex decoding")
    func testSuccessfulComplexDecode() async throws {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let testModel = ComplexTestModel(id: 1,
                                         name: "Complex Test",
                                         metadata: ["key": "value"],
                                         createdAt: Date(timeIntervalSince1970: 0),
                                         isActive: true
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(testModel)
        
        let requestMock = HTTPNetworkServiceDataRequestMock(datas: [
            "https://example.com/1": data
        ])
        let service = HTTPNetworkService(dataRequester: requestMock, decoder: decoder)
        
        let decoded: ComplexTestModel = try await service.perform(.init(baseURL: "https://example.com/1"))
        #expect(decoded == testModel)
    }
    
    @Test("Generic decoding")
    func testSuccessfulGenericDecode() async throws {
        
        let stringArray = ["one", "two", "three"]
        let intArray = [1, 2, 3]
        let dictionary = ["key": "value"]
        
        let stringData = try JSONEncoder().encode(stringArray)
        let intData = try JSONEncoder().encode(intArray)
        let dictData = try JSONEncoder().encode(dictionary)
        
        let requestMock = HTTPNetworkServiceDataRequestMock(datas: [
            "https://example.com/1": stringData,
            "https://example.com/2": intData,
            "https://example.com/3": dictData
        ])
        
        let service = HTTPNetworkService(dataRequester: requestMock)
        
        let decodedStrings: [String] = try await service.perform(.init(baseURL: "https://example.com/1"))
        let decodedInts: [Int] = try await service.perform(.init(baseURL: "https://example.com/2"))
        let decodedDict: [String: String] = try await service.perform(.init(baseURL: "https://example.com/3"))
        
        #expect(decodedStrings == stringArray)
        #expect(decodedInts == intArray)
        #expect(decodedDict == dictionary)
    }
    
    @Test("Decoding error")
    func testDecodingError() async {
        
        let requestMock = HTTPNetworkServiceDataRequestMock(datas: [
            "https://example.com/1": Data([0x00])
        ])
        let service = HTTPNetworkService(dataRequester: requestMock)
        
        do {
            
            let _: TestModel = try await service.perform(.init(baseURL: "https://example.com/1"))
            #expect(Bool(false), "Decoding should have failed")
            
        } catch {
            
            #expect(error is DecodingError)
        }
    }
    
    @Test("Data request mock error (no data)")
    func testRequesterError() async {
        
        let service = HTTPNetworkService(dataRequester: HTTPNetworkServiceDataRequestMock())
        
        do {
            
            let _: TestModel = try await service.perform(.init(baseURL: "https://example.com/1"))
            #expect(Bool(false), "Decoding should have failed")
            
        } catch {
            
            #expect(error as? HTTPNetworkServiceDataRequestMock.Error == .mockDataNotFound)
        }
    }
    
    @Test("Data request mock error (no url match)")
    func testDifferentURLError() async throws {
        let testModel = TestModel(id: 1,
                                  name: "Test")
        let data = try JSONEncoder().encode(testModel)
        
        let requestMock = HTTPNetworkServiceDataRequestMock(datas: [
            "https://example.com/2": data
        ])
        let service = HTTPNetworkService(dataRequester: requestMock)
        
        do {
            
            let _: TestModel = try await service.perform(.init(baseURL: "https://example.com/1"))
            
            #expect(Bool(false), "Request should have failed")
            
        } catch {
            
            #expect(error as? HTTPNetworkServiceDataRequestMock.Error == .mockDataNotFound)
        }
    }
    
    @Test("Multiple concurrent requests")
    func testConcurrentRequests() async throws {
        
        let range = (1...10)
        let models = range.map { TestModel(id: $0, name: "Test \($0)") }
        var mockData: [String: Data] = [:]
        
        for (index, model) in models.enumerated() {
            
            let data = try JSONEncoder().encode(model)
            mockData["https://example.com/\(index + 1)"] = data
        }
        
        let requestMock = HTTPNetworkServiceDataRequestMock(datas: mockData)
        let service = HTTPNetworkService(dataRequester: requestMock)
        
        let results = try await withThrowingTaskGroup(of: TestModel.self) { group in
            
            for index in range {
                
                group.addTask {
                    
                    try await service.perform(.init(baseURL: "https://example.com/\(index)"))
                }
            }
            
            var results: [TestModel] = []
            
            for try await result in group {
                
                results.append(result)
            }
            
            return results.sorted { $0.id < $1.id }
        }
        
        #expect(results.count == 10)
        #expect(results == models)
    }
    
    @Test("Request builder")
    func testRequestBuilder() throws {
        
        var request = try URLRequest(baseURL: "https://example.com/api/resource",
                                     method: .post,
                                     additionalHeaders: ["Authorization": "Bearer 123", "Custom-Header": "Value1"])
        
        #expect(request.url?.absoluteString == "https://example.com/api/resource")
        #expect(request.httpMethod == "POST")
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer 123")
        #expect(request.allHTTPHeaderFields?["Custom-Header"] == "Value1")
        #expect(request.timeoutInterval == 60)
        
        do {
            
            request = try URLRequest(baseURL: "")
            #expect(Bool(false), "URL creation should have failed")
            
        } catch {
            
            #expect(error as? URLRequest.Error == .invalidURL)
        }
        
        request = try URLRequest(baseURL: "https://a.valid.url",
                                 method: .get,
                                 additionalHeaders: ["Custom-Header": "Value2"],
                                 timeout: 2)
        
        #expect(request.url?.absoluteString == "https://a.valid.url")
        #expect(request.httpMethod == "GET")
        #expect(request.allHTTPHeaderFields?["Authorization"] == nil)
        #expect(request.allHTTPHeaderFields?["Custom-Header"] == "Value2")
        #expect(request.timeoutInterval == 2)
    }
    
}

@Suite("URLSessionTests", .serialized)
struct URLSessionTests {

    @Test("URLSession.shared No Response")
    func testURLSessionRequestNoResponse() async throws {
                
        URLSessionMock.requestHandler = { request in nil }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLSessionMock.self]
        let session = URLSession(configuration: config)

        let url = URL(string: "https://example.com/1")!
        let request = URLRequest(url: url)
        
        do {
            
            _ = try await session.requestData(for: request)
            
            #expect(Bool(false), "Request should have failed")
            
        } catch {
            
            switch error as? HTTPNetworkServiceDataRequestProtocolError {
                
            case let .badNetwork(error):
                #expect(error.domain == "No Response or data")
                #expect(error.code == -999)
                
            default:
                #expect(Bool(false), "Error is unexpected")
            }
        }
    }
    
    @Test("URLSession.shared Response Valid",
          arguments: [200, 201, 202, 203, 299, 300, 303])
    func testURLSessionRequestDataSuccess(_ statusCode: Int) async throws {
                
        let expectedData = "success".data(using: .utf8)!
        URLSessionMock.requestHandler = { request in
            
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, expectedData)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLSessionMock.self]
        let session = URLSession(configuration: config)

        let url = URL(string: "https://example.com/1")!
        let request = URLRequest(url: url)
        let data = try await session.requestData(for: request)
        #expect(data == expectedData)
    }

    @Test("URLSession.shared Response Invalid 400",
          arguments: [400, 401, 402, 403, 404])
    func testURLSessionRequestData4XXFailure(_ statusCode: Int) async {
        
        URLSessionMock.requestHandler = { request in
            
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLSessionMock.self]
        let session = URLSession(configuration: config)

        let url = URL(string: "https://example.com/1")!
        let request = URLRequest(url: url)
        
        do {
            
            let _ = try await session.requestData(for: request)
            
            #expect(Bool(false), "Expected error for 5XX response")
            
        } catch {
            
            switch error as? HTTPNetworkServiceDataRequestProtocolError {
                
            case let .badClient(_, response):
                #expect(response.statusCode == statusCode)
                
            default:
                #expect(Bool(false), "Error is unexpected")
            }
        }
    }
    
    @Test("URLSession.shared Response Invalid 500",
          arguments: [500, 501, 502])
    func testURLSessionRequestData5XXFailure(_ statusCode: Int) async {
        
        URLSessionMock.requestHandler = { request in
            
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLSessionMock.self]
        let session = URLSession(configuration: config)

        let url = URL(string: "https://example.com/1")!
        let request = URLRequest(url: url)
        
        do {
            
            let _ = try await session.requestData(for: request)
            
            #expect(Bool(false), "Expected error for 5XX response")
            
        } catch {
            
            switch error as? HTTPNetworkServiceDataRequestProtocolError {
                
            case let .badServer(_, response):
                #expect(response.statusCode == statusCode)
                
            default:
                #expect(Bool(false), "Error is unexpected")
            }
        }
    }
}
