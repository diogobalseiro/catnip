//
//  CatBreedsUseCaseTests.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Testing
import Foundation
import CatsKitDomain
import CatsKitDomainStaging

@Suite("CatBreedsUseCase")
struct CatBreedsUseCaseTests {
    
    final class MockCatBreedsRepository: CatBreedsRepositoryProtocol {
        
        func breeds(limit: String,
                    page: String) async throws -> [CatBreed] {
            
            switch page {
                
            case "0":
                CatBreed.allMocksPage0
                
            case "1":
                CatBreed.allMocksPage1
                
            default: []
            }
        }
    }
    
    @Test("Returns cat breeds")
    func testSuccessfulExecution() async throws {

        let useCase = CatBreedsUseCase(repository: MockCatBreedsRepository())
        let result0 = try await useCase.execute(limit: "10", page: "0")

        #expect(result0 == CatBreed.allMocksPage0)
        
        let result1 = try await useCase.execute(limit: "10", page: "1")

        #expect(result1 == CatBreed.allMocksPage1)
    }
    
    @Test("Supports concurrency")
    func testConcurrentCalls() async throws {

        let useCase = CatBreedsUseCase(repository: MockCatBreedsRepository())

        async let result1 = useCase.execute(limit: "10", page: "0")
        async let result2 = useCase.execute(limit: "10", page: "0")
        async let result3 = useCase.execute(limit: "10", page: "0")

        let results = try await [result1, result2, result3]
        
        for result in results {
            
            #expect(result == CatBreed.allMocksPage0)
        }
    }
}
