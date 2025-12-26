//
//  CatsKitServiceDTOTests.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Testing
import Foundation
import CatsKitDomain
import CatsKitDomainStaging
import CatsKitService
import CatsKitServiceStaging
import HTTPNetworkService
import HTTPNetworkServiceStaging

@Suite("CatsKitServiceDTO")
struct CatsKitServiceDTOTests {

    @Test("Model convertions")
    func testModelConvertions() async throws {
        
        let originalBreeds = CatBreed.allMocks

        let mappedBreeds = originalBreeds.map { CatBreedDTO.fromDomain($0) }

        let recompiledBreeds = mappedBreeds.map { $0.toDomain() }

        #expect(originalBreeds == recompiledBreeds)
    }
}
