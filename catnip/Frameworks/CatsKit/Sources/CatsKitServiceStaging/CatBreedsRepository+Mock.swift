//
//  CatBreedsRepository+Mock.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import HTTPNetworkService
import HTTPNetworkServiceStaging
import CatsKitDomain
import CatsKitService

public extension CatBreedsRepository {

    /// Mock repository that loads its content from a local json file
    static var mock: CatBreedsRepository {

        let config = Service.Config(baseURL: "https://my-mock-server-somewhere.com/api", apiKey: "123")
        let limit = "10"
        let page = "0"
        var datas: [String: Data] = [:]

        if let url = try? ServiceEndpoint.breeds(limit: limit,
                                                 page: page)
            .urlRequest(config: config).url?.absoluteString,
           let data = CatBreedDTO.mockData(page: 0) {

            datas[url] = data

        } else {

            assertionFailure("Failed to encode mock data, repository will not behave correctly")
        }

        let service = Service(config: config,
                              networkService: HTTPNetworkService(dataRequester: HTTPNetworkServiceDataRequestMock(datas: datas)))

        return CatBreedsRepository(apiService: service)
    }
}
