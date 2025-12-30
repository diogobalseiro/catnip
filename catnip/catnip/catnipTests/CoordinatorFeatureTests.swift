//
//  CoordinatorFeatureTests.swift
//  catnip
//
//  Created by Diogo Balseiro on 29/12/2025.
//

import Testing
@testable import catnip
import ComposableArchitecture
import CatsKitDomain
import Foundation
import CatsKitDomainStaging
import Combine
import SwiftUI

extension FeatureTests {
    
    @Suite("CoordinatorFeature")
    @MainActor
    struct CoordinatorFeatureTests {
        
        /// Tests that the onAppear action correctly sets the appeared flag on first appearance.
        ///
        /// This test verifies:
        /// - The appeared flag starts as false
        /// - After sending onAppear, the appeared flag becomes true
        /// - Reachability monitoring is started
        /// - Initial connected state is set
        @Test func onAppear() async throws {
            
            let core = try await makeTestCore()
            let reach = try #require(core.managers.reachability as? Reachability.Mock)

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            #expect(store.state.connected == true)
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.connected = true
            }
            
            // Receive initial reachability value
            await store.receive(\.reachabilityChanged, timeout: .seconds(1))
            
            // Complete the test by ensuring no more effects are running
            reach.subject.send(completion: .finished)
        }
        
        /// Tests that onAppear is idempotent - calling it multiple times has no effect after the first call.
        ///
        /// This test verifies:
        /// - First onAppear sets appeared to true
        /// - Subsequent onAppear calls do nothing
        @Test func onAppearIdempotency() async throws {
            
            let core = try await makeTestCore()
            let reach = try #require(core.managers.reachability as? Reachability.Mock)
            
            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
            }
            
            // First onAppear
            await store.send(.onAppear) {
                $0.appeared = true
                $0.connected = true
            }
            
            // Receive the reachability change
            await store.receive(\.reachabilityChanged, timeout: .seconds(1))
            
            // Second onAppear should do nothing
            await store.send(.onAppear)
            
            // Complete the test
            reach.subject.send(completion: .finished)
        }
        
        /// Tests reachability changes from connected to disconnected.
        ///
        /// This test verifies:
        /// - Reachability changes are properly received
        /// - State reflects the connectivity status
        /// - Tab tint color changes appropriately
        @Test func reachabilityChangeToDisconnected() async throws {
            
            let core = try await makeTestCore()
            let reach = try #require(core.managers.reachability as? Reachability.Mock)
            reach.subject.send(true)

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
            }
            
            await store.send(.onAppear) {
                $0.appeared = true
                $0.connected = true
            }
            
            // Receive initial reachability
            await store.receive(\.reachabilityChanged, timeout: .seconds(1))
            
            // Simulate reachability loss
            reach.subject.send(false)
            
            await store.receive(\.reachabilityChanged, timeout: .seconds(1)) {
                $0.connected = false
            }
            
            // Verify tab tint color reflects disconnected state
            #expect(store.state.tabTintColor == .red)
            
            // Complete the test
            reach.subject.send(completion: .finished)
        }
        
        /// Tests reachability changes from disconnected to connected.
        ///
        /// This test verifies:
        /// - Reachability restoration is properly handled
        /// - State reflects the restored connectivity
        /// - Tab tint color returns to normal
        @Test func reachabilityChangeToConnected() async throws {
            
            let core = try await makeTestCore()
            let reach = try #require(core.managers.reachability as? Reachability.Mock)
            reach.subject.send(false)

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
            }
            
            await store.send(.onAppear) {
                $0.appeared = true
                $0.connected = false
            }
            
            // Receive initial reachability
            await store.receive(\.reachabilityChanged, timeout: .seconds(1))
            
            #expect(store.state.tabTintColor == .red)
            
            // Simulate reachability restoration
            reach.subject.send(true)
            
            await store.receive(\.reachabilityChanged, timeout: .seconds(1)) {
                $0.connected = true
            }
            
            // Verify tab tint color reflects connected state
            #expect(store.state.tabTintColor == .accent)
            
            // Complete the test
            reach.subject.send(completion: .finished)
        }
        
        /// Tests navigation from home to detail view.
        ///
        /// This test verifies:
        /// - Tapping a breed in home triggers navigation
        /// - Detail state is appended to the home path
        /// - The breed data is correctly passed to the detail view
        @Test func homeBreedTappedNavigation() async throws {
            
            let breed = CatBreed.mockAbyssinian

            let core = try await makeTestCore(insert: [breed])
            
            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
            }
            
            // Verify initial path is empty
            #expect(store.state.homePath.isEmpty == true)
            
            // Tap breed in home
            await store.send(.home(.breedTapped(breed))) {
                $0.homePath.append(.detail(DetailFeature.State(catBreed: breed)))
            }
            
            // Verify path now contains one element
            #expect(store.state.homePath.count == 1)
        }
        
        /// Tests navigation from favorites to detail view.
        ///
        /// This test verifies:
        /// - Tapping a breed in favorites triggers navigation
        /// - Detail state is appended to the favorites path
        /// - The breed data is correctly passed to the detail view
        @Test func favoritesBreedTappedNavigation() async throws {
            
            let breed = CatBreed.mockAegean

            let core = try await makeTestCore(insert: [breed])
            
            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
            }
            
            // Verify initial path is empty
            #expect(store.state.favoritesPath.isEmpty == true)
            
            // Tap breed in favorites
            await store.send(.favorites(.breedTapped(breed))) {
                $0.favoritesPath.append(.detail(DetailFeature.State(catBreed: breed)))
            }
            
            // Verify path now contains one element
            #expect(store.state.favoritesPath.count == 1)
        }
        
        /// Tests that favoriting from home broadcasts to favorites and all detail views.
        ///
        /// This test verifies:
        /// - Home broadcast is received by coordinator
        /// - Favorites feature receives favoriteActionFromOutside
        /// - All detail views in both paths receive the update
        @Test func homeFavoriteBroadcast() async throws {
            
            let unfavoritedBreed = CatBreed.mockAbyssinian
            let core = try await makeTestCore(insert: [unfavoritedBreed])
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
                $0.environment = core.environment
                $0.date.now = favoritedDate
            }
                        
            // Initialize favorites feature so it's in .ready state
            await store.send(.favorites(.onAppear)) {
                $0.favorites.appeared = true
                $0.favorites.browsingModeState = .bootstrapping
            }
            await store.receive(\.favorites.bootstrappingSucceeded, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: [])
            }
            
            // Add breed to home path to test broadcast to detail views
            await store.send(.home(.breedTapped(unfavoritedBreed))) {
                $0.homePath.append(.detail(DetailFeature.State(catBreed: unfavoritedBreed)))
            }
            
            // Send favorite broadcast from home
            await store.send(.home(.broadcast(.homeFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true))))
            
            // Favorites feature should receive the action
            await store.receive(\.favorites.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }
            
            // Detail view in home path should receive the action
            await store.receive(\.homePath[id: store.state.homePath.ids.first!].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.homePath[id: store.state.homePath.ids.first!] = .detail(DetailFeature.State(catBreed: favoritedBreed))

            }
        }
        
        /// Tests that unfavoriting from favorites broadcasts to home and all detail views.
        ///
        /// This test verifies:
        /// - Favorites broadcast is received by coordinator
        /// - Home feature receives favoriteActionFromOutside
        /// - All detail views in both paths receive the update
        @Test func favoritesUnfavoriteBroadcast() async throws {
            
            let unfavoritedBreed = CatBreed.mockAbyssinian
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)
            let core = try await makeTestCore(insert: [favoritedBreed])

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
                $0.environment = core.environment
                $0.date.now = favoritedDate
            }
                        
            // Initialize favorites feature so it's in .ready state
            await store.send(.favorites(.onAppear)) {
                $0.favorites.appeared = true
                $0.favorites.browsingModeState = .bootstrapping
            }
            await store.receive(\.favorites.bootstrappingSucceeded, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: [favoritedBreed])
            }

            // Add breed to favorites path to test broadcast to detail views
            await store.send(.favorites(.breedTapped(favoritedBreed))) {
                $0.favoritesPath.append(.detail(DetailFeature.State(catBreed: favoritedBreed)))
            }
                        
            // Send unfavorite broadcast from favorites
            await store.send(.favorites(.broadcast(.favoritesFeatureUnfavorited(breed: unfavoritedBreed))))
            
            // Home feature should receive the action
            await store.receive(\.home.favoriteActionFromOutside, timeout: .seconds(1))
            
            // Detail view in favorites path should receive the action
            await store.receive(\.favoritesPath[id: store.state.favoritesPath.ids.first!].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favoritesPath[id: store.state.favoritesPath.ids.first!] = .detail(DetailFeature.State(catBreed: unfavoritedBreed))
            }
        }
        
        /// Tests that favoriting from a detail view in home path broadcasts to all features.
        ///
        /// This test verifies:
        /// - Detail broadcast from home path is received
        /// - Home feature receives favoriteActionFromOutside
        /// - Favorites feature receives favoriteActionFromOutside
        /// - All other detail views receive the update
        @Test func homePathDetailFavoriteBroadcast() async throws {
            
            let unfavoritedBreed = CatBreed.mockAbyssinian
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)
            let core = try await makeTestCore(insert: [unfavoritedBreed])

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
                $0.environment = core.environment
                $0.date.now = favoritedDate
            }
                
            // Initialize favorites feature so it's in .ready state
            await store.send(.favorites(.onAppear)) {
                $0.favorites.appeared = true
                $0.favorites.browsingModeState = .bootstrapping
            }
            await store.receive(\.favorites.bootstrappingSucceeded, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: [])
            }
            
            // Add breed to home path
            await store.send(.home(.breedTapped(unfavoritedBreed))) {
                $0.homePath.append(.detail(DetailFeature.State(catBreed: unfavoritedBreed)))
            }
            
            let pathId = store.state.homePath.ids.first!
            
            // Send favorite broadcast from detail in home path
            await store.send(.homePath(.element(id: pathId, action: .detail(.broadcast(.detailFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true))))))
            
            // Home feature should receive the action
            await store.receive(\.home.favoriteActionFromOutside, timeout: .seconds(1))
            
            // Favorites feature should receive the action
            await store.receive(\.favorites.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }
            
            // The same detail view should also receive its own broadcast
            await store.receive(\.homePath[id: pathId].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.homePath[id: pathId] = .detail(DetailFeature.State(catBreed: favoritedBreed))
            }
        }
        
        /// Tests that favoriting from a detail view in favorites path broadcasts to all features.
        ///
        /// This test verifies:
        /// - Detail broadcast from favorites path is received
        /// - Home feature receives favoriteActionFromOutside
        /// - Favorites feature receives favoriteActionFromOutside
        /// - All other detail views receive the update
        @Test func favoritesPathDetailFavoriteBroadcast() async throws {
            
            let unfavoritedBreed = CatBreed.mockAbyssinian
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)
            let core = try await makeTestCore(insert: [unfavoritedBreed])

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
                $0.environment = core.environment
            }
                        
            // Initialize favorites feature so it's in .ready state
            await store.send(.favorites(.onAppear)) {
                $0.favorites.appeared = true
                $0.favorites.browsingModeState = .bootstrapping
            }
            await store.receive(\.favorites.bootstrappingSucceeded, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: [])
            }
            
            // Add breed to favorites path
            await store.send(.favorites(.breedTapped(unfavoritedBreed))) {
                $0.favoritesPath.append(.detail(DetailFeature.State(catBreed: unfavoritedBreed)))
            }
            
            let pathId = store.state.favoritesPath.ids.first!
            
            // Send favorite broadcast from detail in favorites path
            await store.send(.favoritesPath(.element(id: pathId, action: .detail(.broadcast(.detailFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true))))))
            
            // Home feature should receive the action
            await store.receive(\.home.favoriteActionFromOutside, timeout: .seconds(1))
            
            // Favorites feature should receive the action
            await store.receive(\.favorites.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }
            
            // The same detail view should also receive its own broadcast
            await store.receive(\.favoritesPath[id: pathId].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favoritesPath[id: pathId] = .detail(DetailFeature.State(catBreed: favoritedBreed))
            }
        }
        
        /// Tests complex navigation scenario with multiple detail views.
        ///
        /// This test verifies:
        /// - Multiple detail views can be added to each path
        /// - Broadcasts reach all detail views in both paths
        /// - Navigation state is properly maintained
        @Test func multipleDetailViewsBroadcast() async throws {
            
            let favoritedDate = Date()
            let favoriteBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let unfavoriteBreed = CatBreed.mockAbyssinian

            let core = try await makeTestCore(insert: [favoriteBreed])

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
                $0.environment = core.environment
                $0.date.now = favoritedDate
            }
                    
            // Add one breed to home path
            await store.send(.home(.breedTapped(favoriteBreed))) {
                $0.homePath.append(.detail(DetailFeature.State(catBreed: favoriteBreed)))
            }
                        
            // Add one breed to favorites path
            await store.send(.favorites(.breedTapped(favoriteBreed))) {
                $0.favoritesPath.append(.detail(DetailFeature.State(catBreed: favoriteBreed)))
            }
                        
            // Verify we have 1 detail view in each path
            #expect(store.state.homePath.count == 1)
            #expect(store.state.favoritesPath.count == 1)
            
            let homePathIds = Array(store.state.homePath.ids)
            let favoritesPathIds = Array(store.state.favoritesPath.ids)
            
            // Send unfavorite broadcast from favorites
            await store.send(.favorites(.broadcast(.favoritesFeatureUnfavorited(breed: unfavoriteBreed))))
            
            // Home feature should receive the action
            await store.receive(\.home.favoriteActionFromOutside, timeout: .seconds(1))
            
            // The detail view in home path should receive the action and update its breed
            await store.receive(\.homePath[id: homePathIds[0]].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.homePath[id: homePathIds[0]] = .detail(DetailFeature.State(catBreed: unfavoriteBreed))
            }
            
            // The detail view in favorites path should receive the action and update its breed
            await store.receive(\.favoritesPath[id: favoritesPathIds[0]].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favoritesPath[id: favoritesPathIds[0]] = .detail(DetailFeature.State(catBreed: unfavoriteBreed))
            }
        }
        
        /// Tests the complete lifecycle of favoriting coordination across all features.
        ///
        /// This test verifies:
        /// - Coordinator properly handles initialization
        /// - Navigation works correctly
        /// - Favorite actions propagate through the entire coordinator hierarchy
        /// - State consistency is maintained across home, favorites, and detail views
        @Test func completeCoordinationLifecycle() async throws {
            
            let core = try await makeTestCore()
            let reach = try #require(core.managers.reachability as? Reachability.Mock)
            reach.subject.send(true)
            let favoritedDate = Date()

            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
                $0.environment = core.environment
                $0.date.now = favoritedDate
            }
            
            let allMocksPage0 = CatBreed.allMocksPage0
            let unfavoritedBreed = allMocksPage0.first!
            let favoritedBreed = CatBreed.make(from: unfavoritedBreed, favorited: favoritedDate)

            // Initialize coordinator
            await store.send(.onAppear) {
                $0.appeared = true
                $0.connected = true
            }
            
            // Receive initial reachability
            await store.receive(\.reachabilityChanged, timeout: .seconds(1))

            // Initialize home feature so it's in .ready state
            await store.send(.home(.onAppear)) {
                $0.home.appeared = true
                $0.home.visualState = .bootstrapping
            }
            await store.receive(\.home.bootstrappingSucceeded, timeout: .seconds(1)) {
                $0.home.browsingModeState = .init(breeds: IdentifiedArray(uniqueElements: allMocksPage0))
                $0.home.visualState = .ready
            }

            // Initialize favorites feature so it's in .ready state
            await store.send(.favorites(.onAppear)) {
                $0.favorites.appeared = true
                $0.favorites.browsingModeState = .bootstrapping
            }
            await store.receive(\.favorites.bootstrappingSucceeded, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: [])
            }
            
            // Navigate to detail from home
            await store.send(.home(.breedTapped(unfavoritedBreed))) {
                $0.homePath.append(.detail(DetailFeature.State(catBreed: unfavoritedBreed)))
            }
            
            let homePathId = store.state.homePath.ids.first!
            
            // Favorite from detail view
            await store.send(.homePath(.element(id: homePathId, action: .detail(.broadcast(.detailFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true))))))
            
            let homeBreeds = [favoritedBreed] + allMocksPage0.dropFirst(1).map(\.self)
            
            // Verify broadcasts reach all features
            await store.receive(\.home.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.home.browsingModeState = .init(breeds: IdentifiedArray(uniqueElements: homeBreeds))
            }
            await store.receive(\.favorites.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }
            await store.receive(\.homePath[id: homePathId].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.homePath[id: homePathId] = .detail(DetailFeature.State(catBreed: favoritedBreed))
            }
            
            // Navigate to same breed from favorites
            await store.send(.favorites(.breedTapped(favoritedBreed))) {
                $0.favoritesPath.append(.detail(DetailFeature.State(catBreed: favoritedBreed)))
            }
            
            let favoritesPathId = store.state.favoritesPath.ids.first!
            
            // Unfavorite from favorites detail view
            await store.send(.favoritesPath(.element(id: favoritesPathId, action: .detail(.broadcast(.detailFeatureFavoriteAction(breed: unfavoritedBreed, newDesiredState: false))))))
            
            // Verify broadcasts reach all features
            await store.receive(\.home.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.home.browsingModeState = .init(breeds: IdentifiedArray(uniqueElements: allMocksPage0))
            }
            await store.receive(\.favorites.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favorites.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: []))
            }
            await store.receive(\.homePath[id: homePathId].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.homePath[id: homePathId] = .detail(DetailFeature.State(catBreed: unfavoritedBreed))
            }
            await store.receive(\.favoritesPath[id: favoritesPathId].detail.favoriteActionFromOutside, timeout: .seconds(1)) {
                $0.favoritesPath[id: favoritesPathId] = .detail(DetailFeature.State(catBreed: unfavoritedBreed))
            }
            
            // Simulate connectivity loss
            reach.subject.send(false)
            await store.receive(\.reachabilityChanged, timeout: .seconds(1)) {
                $0.connected = false
            }
            
            // Verify state reflects connectivity loss
            #expect(store.state.connected == false)
            #expect(store.state.tabTintColor == .red)
            
            // Complete the test
            reach.subject.send(completion: .finished)
        }
        
        /// Tests that non-broadcast actions from child features don't trigger coordinator actions.
        ///
        /// This test verifies:
        /// - Regular child feature actions pass through without side effects
        /// - Only broadcast actions trigger coordinator logic
        @Test func nonBroadcastActionsPassThrough() async throws {
            
            let core = try await makeTestCore()
            
            let store = TestStore(initialState: CoordinatorFeature.State()) {
                CoordinatorFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.reachability = core.managers.reachability
                $0.environment = core.environment
            }
            
            // We need to enable exhaustivity to properly test, but we'll allow
            // non-exhaustive actions that don't affect coordinator state
            store.exhaustivity = .off
            
            // Send non-broadcast actions that should just pass through
            await store.send(.home(.onAppear))
            
            // Home will bootstrap and succeed
            await store.receive(\.home.bootstrappingSucceeded, timeout: .seconds(1))
            
            await store.send(.favorites(.onAppear))
            
            // Favorites will bootstrap and succeed
            await store.receive(\.favorites.bootstrappingSucceeded, timeout: .seconds(1))
            
            // These should complete without any coordinator-level effects
            await store.finish()
        }
    }
}
