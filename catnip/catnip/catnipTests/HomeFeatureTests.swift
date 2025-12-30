//
//  HomeFeatureTests.swift
//  catnip
//
//  Created by Diogo Balseiro on 29/12/2025.
//

import Testing
@testable import catnip
import ComposableArchitecture
import CatsKitDomain
import CatsKitService
import Foundation
import CatsKitDomainStaging
import HTTPNetworkService
import HTTPNetworkServiceStaging
import Combine

extension FeatureTests {
    
    @Suite("HomeFeature")
    @MainActor
    struct HomeFeatureTests {
        
        @Test func onAppearBootstrappingSucceeded() async throws {
            
            let core = try await makeTestCore()

            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
            
            let breedsPage = CatBreed.allMocksPage0
            
            await store.receive(.bootstrappingSucceeded(breedsPage), timeout: .seconds(1)) {
                $0.visualState = .ready
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage))
            }
        }
        
        @Test func onAppearBootstrappingFailed() async throws {
            
            let core = try await makeTestCore()
            try await core.updateCatBreedsPageFailedData()
            
            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
                        
            await store.receive(.bootstrappingFailed, timeout: .seconds(1)) {
                $0.visualState = .idle
                $0.appeared = false
            }
        }
        
        @Test func favoriteAndUnfavoriteActionSuccess() async throws {
            
            let breedsPage = CatBreed.allMocksPage0
            let unfavoritedBreed = breedsPage.first!
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)

            let core = try await makeTestCore()

            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.date.now = favoritedDate
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded(breedsPage), timeout: .seconds(1)) {
                $0.visualState = .ready
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage))
            }

            let newBreeds = [favoritedBreed] + breedsPage.dropFirst(1).map(\.self)

            // Send favorite action
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: true))
            
            await store.receive(.favoriteActionSucceeded(catBreed: favoritedBreed), timeout: .seconds(1)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: newBreeds))
            }
            
            // Verify broadcast was sent
            await store.receive(.broadcast(.homeFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true)))
            
            // Send favorite action
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: false))
            
            await store.receive(.favoriteActionSucceeded(catBreed: unfavoritedBreed), timeout: .seconds(1)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: breedsPage))
            }
            
            // Verify broadcast was sent
            await store.receive(.broadcast(.homeFeatureFavoriteAction(breed: unfavoritedBreed, newDesiredState: false)))
        }
        
        @Test func favoriteActionDebouncing() async throws {
            
            let breedsPage = CatBreed.allMocksPage0
            let unfavoritedBreed = breedsPage.first!
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)

            let core = try await makeTestCore()

            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.date.now = favoritedDate
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded(breedsPage), timeout: .seconds(1)) {
                $0.visualState = .ready
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage))
            }

            let newBreeds = [favoritedBreed] + breedsPage.dropFirst(1).map(\.self)

            // Send favorite action
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: true))

            await store.receive(.favoriteActionSucceeded(catBreed: favoritedBreed), timeout: .seconds(1)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: newBreeds))
            }
            
            // Verify broadcast was sent
            await store.receive(.broadcast(.homeFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true)))
        }
        
        @Test func favoriteActionFromOutsideMatchingBreed() async throws {
            
            let breedsPage = CatBreed.allMocksPage0
            let unfavoritedBreed = breedsPage.first!
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)

            let core = try await makeTestCore()

            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.date.now = favoritedDate
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded(breedsPage), timeout: .seconds(1)) {
                $0.visualState = .ready
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: breedsPage))
            }
            
            let newBreeds = [favoritedBreed] + breedsPage.dropFirst(1).map(\.self)

            // Send action from outside with matching breed
            await store.send(.favoriteActionFromOutside(catBreed: favoritedBreed)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: newBreeds))
            }
            
            // Send action from outside with matching breed
            await store.send(.favoriteActionFromOutside(catBreed: unfavoritedBreed)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: breedsPage))
            }
        }
        
        @Test func fetchPages() async throws {
            
            let breedsPage0 = CatBreed.allMocksPage0
            let breedsPage1 = CatBreed.allMocksPage1

            let core = try await makeTestCore()

            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded(breedsPage0), timeout: .seconds(1)) {
                $0.visualState = .ready
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage0))
            }

            await store.send(.fetchPageIfNeeded(index: 1))

            await store.send(.fetchPageIfNeeded(index: 8)) {
                $0.browsingModeState.workingOnNewPage = true
            }
            
            await store.receive(.fetchPageSucceeded(newBreeds: breedsPage1), timeout: .seconds(2)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage0 + breedsPage1))
                $0.browsingModeState.workingOnNewPage = false
            }
            
            try await core.updateCatBreedsPageFailedData(page: 2)
            
            await store.send(.fetchPageIfNeeded(index: 18)) {
                $0.browsingModeState.workingOnNewPage = true
            }

            await store.receive(.fetchPageFailed, timeout: .seconds(2)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage0 + breedsPage1))
                $0.browsingModeState.workingOnNewPage = false
            }
        }
        
        @Test func search() async throws {
            
            let breedsPage0 = CatBreed.allMocksPage0

            let core = try await makeTestCore()

            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded(breedsPage0), timeout: .seconds(1)) {
                $0.visualState = .ready
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage0))
            }

            await store.send(.searchBreeds("rag")) {
                $0.searchingModeState.workingOnNewQuery = true
            }
            
            await store.receive(.searchBreedsSucceeded(CatBreed.searchRagMocks), timeout: .seconds(1)) {
                $0.searchingModeState = .init(breeds: IdentifiedArray(uniqueElements: CatBreed.searchRagMocks), workingOnNewQuery: false)
            }

            let reach = try #require(core.managers.reachability as? Reachability.Mock)
            reach.subject.send(false)

            await store.send(.searchBreeds("abyssinian")) {
                $0.searchingModeState.workingOnNewQuery = true
                $0.searchingModeState.breeds = []
            }
            
            await store.receive(.searchBreedsSucceeded([.mockAbyssinian]), timeout: .seconds(1)) {
                $0.searchingModeState = .init(breeds: IdentifiedArray(uniqueElements: [.mockAbyssinian]), workingOnNewQuery: false)
            }
        }

        @Test func completeLifecycle() async throws {
            
            let breedsPage0 = CatBreed.allMocksPage0
            let breedsPage1 = CatBreed.allMocksPage1
            let unfavoritedBreed = breedsPage0.first!
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)

            let core = try await makeTestCore()

            let store = TestStore(initialState: HomeFeature.State()) {
                HomeFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.date.now = favoritedDate
            }
            
            // 1. Bootstrap on appear
            #expect(store.state.appeared == false)
            #expect(store.state.visualState == .idle)

            await store.send(.onAppear) {
                $0.appeared = true
                $0.visualState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded(breedsPage0), timeout: .seconds(1)) {
                $0.visualState = .ready
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage0))
            }

            // 2. Favorite a breed in browsing mode
            let newBreedsWithFavorite = [favoritedBreed] + breedsPage0.dropFirst(1).map(\.self)

            await store.send(.favoriteAction(catBreed: unfavoritedBreed, newDesiredState: true))
            
            await store.receive(.favoriteActionSucceeded(catBreed: favoritedBreed), timeout: .seconds(1)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: newBreedsWithFavorite))
            }
            
            await store.receive(.broadcast(.homeFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true)))

            // 3. Fetch next page
            await store.send(.fetchPageIfNeeded(index: 8)) {
                $0.browsingModeState.workingOnNewPage = true
            }
            
            await store.receive(.fetchPageSucceeded(newBreeds: breedsPage1), timeout: .seconds(2)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: newBreedsWithFavorite + breedsPage1))
                $0.browsingModeState.workingOnNewPage = false
            }

            // 4. Search for breeds
            await store.send(.searchBreeds("rag")) {
                $0.searchingModeState.workingOnNewQuery = true
                $0.searchingModeState.breeds = []
            }
            
            await store.receive(.searchBreedsSucceeded(CatBreed.searchRagMocks), timeout: .seconds(1)) {
                $0.searchingModeState = .init(breeds: IdentifiedArray(uniqueElements: CatBreed.searchRagMocks), workingOnNewQuery: false)
            }

            // 5. Receive favorite action from outside (simulating another feature updating a breed)
            let searchedBreed = CatBreed.searchRagMocks.first!
            let favoritedSearchedBreed = CatBreed.make(from: searchedBreed, favorited: favoritedDate)
            
            let updatedSearchResults = [favoritedSearchedBreed] + CatBreed.searchRagMocks.dropFirst(1).map(\.self)
            
            await store.send(.favoriteActionFromOutside(catBreed: favoritedSearchedBreed)) {
                $0.searchingModeState = .init(breeds: IdentifiedArray(uniqueElements: updatedSearchResults), workingOnNewQuery: false)
            }

            let reach = try #require(core.managers.reachability as? Reachability.Mock)
            reach.subject.send(false)

            // 6. Search for another breed
            await store.send(.searchBreeds("aegean")) {
                $0.searchingModeState.workingOnNewQuery = true
                $0.searchingModeState.breeds = []
            }
            
            await store.receive(.searchBreedsSucceeded([.mockAegean]), timeout: .seconds(1)) {
                $0.searchingModeState = .init(breeds: IdentifiedArray(uniqueElements: [.mockAegean]), workingOnNewQuery: false)
            }

            // 7. Unfavorite the original breed
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: false))
            
            await store.receive(.favoriteActionSucceeded(catBreed: unfavoritedBreed), timeout: .seconds(1)) {
                $0.browsingModeState = .init(breeds: IdentifiedArrayOf.init(uniqueElements: breedsPage0 + breedsPage1))
                $0.browsingModeState.workingOnNewPage = false
            }
            
            await store.receive(.broadcast(.homeFeatureFavoriteAction(breed: unfavoritedBreed, newDesiredState: false)))
        }
    }
}

private extension Core {

    func updateCatBreedsPageFailedData(page: Int = 0) async throws {
        
        let apiService = try await #require(services.apiService as? Service)

        let url = try  #require(ServiceEndpoint.breeds(limit: "10",
                                                  page: String(page))
            .urlRequest(config: apiService.config)
            .url?.absoluteString)

        try await self.updateData(Data(), for: url)
    }
    
    func updateData(_ data: Data, for url: String) async throws {
        
        let networkService = try  await #require(services.networkService as? HTTPNetworkService)
        let dataRequester = try #require(networkService.dataRequester as? HTTPNetworkServiceDataRequestMock)
        await dataRequester.updateData(data, for: url)
    }
}
