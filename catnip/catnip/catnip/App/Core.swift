//
//  Core.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Foundation
import CatsKitDomain
import CatsKitService
import HTTPNetworkService
import HTTPNetworkServiceStaging
import CatsKitServiceStaging
import Combine

/// God model that houses global state.
public final class Core {
    
    /// Helpful to differentiate between various environments
    enum Environment: Equatable {

        case live
        case staging(delay: Duration? = nil)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.live, .live): true
            case let (.staging(lhsDelay), .staging(rhsDelay)): lhsDelay == rhsDelay
            default: false
            }
        }
    }

    struct Services {
        
        let networkService: HTTPNetworkServiceProtocol
        let apiService: ServiceProtocol
    }
    
    struct Repositories {
        
        let catBreeds: CatBreedsRepositoryProtocol
        let catBreedsSearch: CatBreedsSearchRepositoryProtocol
    }

    struct Managers {

        let reachability: ReachabilityProtocol
        let catGateway: CatGatewayProtocol
    }

    let services: Services
    let repositories: Repositories
    let managers: Managers

    let environment: Environment

    init(environment: Environment = .live) {


        let config = Service.Config(baseURL: Services.Constants.catsAPIURL,
                                    apiKey: Services.catsAPIKey,
                                    timeout: Services.Constants.timeout)
        let networkService = HTTPNetworkService(dataRequester: Self.makeNetworkServiceDataRequester(with: config,
                                                                                                    environment: environment))
        let apiService = Service(config: config, networkService: networkService)
        let catBreedsRepository = CatBreedsRepository(apiService: apiService)
        let catBreedsSearchRepository = CatBreedsSearchRepository(apiService: apiService)
        let reachability = Self.makeReachability(environment: environment)
        let catGateway = CatGateway(isStoredInMemoryOnly: environment != .live,
                                    breedsUseCase: .init(repository: catBreedsRepository),
                                    breedsSearchUseCase: .init(repository: catBreedsSearchRepository),
                                    reachability: reachability)

        self.environment = environment
        self.services = Services(networkService: networkService,
                                 apiService: apiService)
        self.repositories = Repositories(catBreeds: catBreedsRepository,
                                         catBreedsSearch: catBreedsSearchRepository)
        self.managers = Managers(reachability: reachability,
                                 catGateway: catGateway)
    }
}

private extension Core.Services {
    
    enum Constants {
        
        static let catsAPIURL = "https://api.thecatapi.com/v1"
        static let timeout = 10.0
    }
    
    /// API keys should not be coded in the app's bundle in a prodution app.
    static var catsAPIKey: String {

        guard let key = Bundle.main.object(forInfoDictionaryKey: "CatsAPIKey") as? String else {

            fatalError("CatsAPIKey not found in Info.plist")
        }

        return String(key.reversed())
    }
}

private extension Core {

    static func makeReachability(environment: Environment) -> ReachabilityProtocol {

        switch environment {

        case .live:
            Reachability()

        case .staging:
            Reachability.Mock()
        }
    }

    static func makeNetworkServiceDataRequester(with config: Service.Config,
                                                environment: Environment) -> HTTPNetworkServiceDataRequestProtocol {

        switch environment {
        case .live:
            URLSession.shared
            
        case let .staging(delay):
            HTTPNetworkServiceDataRequestMock.full(with: config,
                                                   delay: delay)
        }
    }
}

extension HTTPNetworkServiceDataRequestMock {

    /// Convenience mock instance
    static func full(with config: Service.Config, delay: Duration?) -> HTTPNetworkServiceDataRequestMock {

        var datas = [String: Data]()

        [0,1,2].forEach { page in

            if let tuple = mockPageData(config: config, page: page) {

                datas[tuple.url] = tuple.data

            } else {

                assertionFailure("Failed to encode mock data, repository will not behave correctly")
            }
        }

        if let tuple = mockSearchData(config: config) {

            datas[tuple.url] = tuple.data

        } else {

            assertionFailure("Failed to encode mock data, repository will not behave correctly")
        }

        return HTTPNetworkServiceDataRequestMock(datas: datas, delay: delay)
    }

    static func mockPageData(config: Service.Config,
                             page: Int) -> (url: String, data: Data)? {

        guard let url = try? ServiceEndpoint.breeds(limit: "10",
                                              page: String(page)).urlRequest(config: config)
            .url?.absoluteString,
              let data = CatBreedDTO.mockData(page: page) else {

            return nil
        }

        return (url, data)
    }
    
    static func mockSearchData(config: Service.Config) -> (url: String, data: Data)? {

        guard let url = try? ServiceEndpoint.searchBreeds(query: "rag").urlRequest(config: config)
            .url?.absoluteString,
              let data = CatBreedDTO.mockDataSearch() else {

            return nil
        }

        return (url, data)
    }
}
