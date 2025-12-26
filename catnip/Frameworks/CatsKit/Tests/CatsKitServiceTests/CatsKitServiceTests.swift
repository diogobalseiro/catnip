//
//  CatsKitServiceTests.swift
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

@Suite("CatsKitService")
struct CatsKitServiceTests {

    let baseURL = "https://my-mock-server-somewhere.com/api"

    @Test("Return cat breeds")
    func testCatBreeds() async throws {

        let config = Service.Config(baseURL: baseURL, apiKey: "123")
        let breedDTOs = CatBreedDTO.allMocks

        let mockData = try #require(CatBreedDTO.mockData(page: 0))

        let mock = HTTPNetworkServiceDataRequestMock(datas: [
            baseURL + "/breeds?limit=10&page=0": mockData
        ])

        let service = Service(config: config,
                              networkService: HTTPNetworkService(dataRequester: mock))

        let responseDTOs: [CatBreedDTO] = try await service
            .breeds(limit: "10", page: "0")

        #expect(responseDTOs == breedDTOs)
    }

    @Test("Search cat breeds")
    func testSearchCatBreeds() async throws {

        let config = Service.Config(baseURL: baseURL, apiKey: "123")
        let breedDTOs = CatBreedDTO.searchRagMocks

        let mockData = try #require(CatBreedDTO.mockDataSearch())

        let mock = HTTPNetworkServiceDataRequestMock(datas: [
            baseURL + "/breeds/search?q=rag": mockData
        ])

        let service = Service(config: config,
                              networkService: HTTPNetworkService(dataRequester: mock))

        let responseDTOs: [CatBreedDTO] = try await service
            .searchBreeds(query: "rag")

        #expect(responseDTOs == breedDTOs)
    }

    @Test("Repository integration test")
    func testRepositoryIntegration() async throws {

        let repository = CatBreedsRepository.mock

        let breeds = try await repository.breeds(limit: "10", page: "0")

        #expect(breeds.first?.id == "abys")
        #expect(breeds.first?.name == "Abyssinian")
        #expect(breeds.first?.temperament == "Active, Energetic, Independent, Intelligent, Gentle")
        #expect(breeds.first?.origin == "Egypt")
        #expect(breeds.first?.catDescription == "The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.")
        #expect(breeds.first?.lifeSpan == "14 - 15")
        #expect(breeds.first?.imageURL == "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")

        #expect(breeds.last?.id == "bamb")
        #expect(breeds.last?.name == "Bambino")
        #expect(breeds.last?.temperament == "Affectionate, Lively, Friendly, Intelligent")
        #expect(breeds.last?.origin == "United States")
        #expect(breeds.last?.catDescription == "The Bambino is a breed of cat that was created as a cross between the Sphynx and the Munchkin breeds. The Bambino cat has short legs, large upright ears, and is usually hairless. They love to be handled and cuddled up on the laps of their family members.")
        #expect(breeds.last?.lifeSpan == "12 - 14")
        #expect(breeds.last?.imageURL == "https://cdn2.thecatapi.com/images/5AdhMjeEu.jpg")
    }

    @Test("Endpoint Breeds URL construction",
          arguments: [
            (
             "1",
             "0",
             "/breeds?limit=1&page=0"),
            (
             "10",
             "2",
             "/breeds?limit=10&page=2"),
            (
             "100",
             "3",
             "/breeds?limit=100&page=3"),
          ])
    func testBreedsEndpointURLConstruction(_ limit: String,
                                     _ page: String,
                                     _ url: String) throws {

        let config = Service.Config(baseURL: baseURL, apiKey: "123")

        let request = try ServiceEndpoint.breeds(limit: limit, page: page)
            .urlRequest(config: config)

        #expect(request.url?.absoluteString == baseURL + url)
        #expect(request.httpMethod == URLRequest.Method.get.rawValue)
    }

    @Test("Endpoint Search Breeds URL construction",
          arguments: [
            (
             "rag",
             "/breeds/search?q=rag"),
            (
             "short",
             "/breeds/search?q=short"),
            (
             "air",
             "/breeds/search?q=air"),
          ])

    func testSearchEndpointURLConstruction(_ query: String,
                                           _ url: String) throws {

        let config = Service.Config(baseURL: baseURL, apiKey: "123")

        let request = try ServiceEndpoint.searchBreeds(query: query)
            .urlRequest(config: config)

        #expect(request.url?.absoluteString == baseURL + url)
        #expect(request.httpMethod == URLRequest.Method.get.rawValue)
    }
}
