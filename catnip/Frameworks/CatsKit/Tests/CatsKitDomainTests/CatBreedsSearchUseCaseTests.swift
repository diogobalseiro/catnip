//
//  CatBreedsSearchUseCaseTests.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Testing
import Foundation
import CatsKitDomain
import CatsKitDomainStaging

@Suite("CatBreedsSearchUseCase")
struct CatBreedsSearchUseCaseTests {

    final class MockCatBreedsSearchRepository: CatBreedsSearchRepositoryProtocol {

        func searchBreeds(query: String) async throws -> [CatBreed] {

            CatBreed.allMocks
        }
    }

    @Test("Returns cat breeds")
    func testSuccessfulExecution() async throws {

        let useCase = CatBreedsSearchUseCase(repository: MockCatBreedsSearchRepository())
        let result = try await useCase.execute(query: "rag")

        #expect(result == CatBreed.allMocks)
    }

    @Test("Supports concurrency")
    func testConcurrentCalls() async throws {

        let useCase = CatBreedsSearchUseCase(repository: MockCatBreedsSearchRepository())

        async let result1 = useCase.execute(query: "rag")
        async let result2 = useCase.execute(query: "rag")
        async let result3 = useCase.execute(query: "rag")

        let results = try await [result1, result2, result3]

        for result in results {

            #expect(result == CatBreed.allMocks)
        }
    }
}
