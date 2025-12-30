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

            CatBreed.allMocksPage0
        }
    }
    
    @Test("Returns cat breeds")
    func testSuccessfulExecution() async throws {

        let useCase = CatBreedsUseCase(repository: MockCatBreedsRepository())
        let result = try await useCase.execute(limit: "10", page: "0")

        #expect(result == CatBreed.allMocksPage0)
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
