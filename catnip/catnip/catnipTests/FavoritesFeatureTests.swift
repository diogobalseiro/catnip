//
//  FavoritesFeatureTests.swift
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

extension FeatureTests {
    
    @Suite("FavoritesFeature")
    @MainActor
    struct FavoritesFeatureTests {
        
        /// Tests that the onAppear action correctly sets the appeared flag on first appearance.
        ///
        /// This test verifies:
        /// - The appeared flag starts as false
        /// - After sending onAppear, the appeared flag becomes true
        /// - No effects are triggered
        @Test func onAppear() async throws {
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let unfavoritedBreed = CatBreed.mockAegean

            let core = try await makeTestCore(insert: [unfavoritedBreed, favoritedBreed])
            
            let store = TestStore(initialState: FavoritesFeature.State()) {
                FavoritesFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
                $0.date.now = favoritedDate
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.browsingModeState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded([favoritedBreed]), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }
        }
        
        @Test func favoriteActionSuccess() async throws {
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)

            let core = try await makeTestCore(insert: [favoritedBreed])
                        
            let store = TestStore(initialState: FavoritesFeature.State()) {
                FavoritesFeature()
            } withDependencies: {
                $0.date.now = favoritedDate
                $0.catGateway = core.managers.catGateway
            }
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.browsingModeState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded([favoritedBreed]), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }

            // Send favorite action (this is ignored when breed is already favorited)
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: true))
            
            // Wait for the debounced effect to complete
            await store.finish()
        }
        

        @Test func unfavoriteActionSuccess() async throws {
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let unfavoritedBreed = CatBreed.mockAbyssinian

            let core = try await makeTestCore(insert: [favoritedBreed])
                        
            let store = TestStore(initialState: FavoritesFeature.State()) {
                FavoritesFeature()
            } withDependencies: {
                $0.date.now = favoritedDate
                $0.catGateway = core.managers.catGateway
            }
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.browsingModeState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded([favoritedBreed]), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }

            // Send unfavorite action
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: false))

            // Wait for debounce and verify success action
            await store.receive(.unfavoriteActionSucceeded(catBreed: unfavoritedBreed), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: []))
            }
            
            // Verify broadcast was sent
            await store.receive(.broadcast(.favoritesFeatureUnfavorited(breed: unfavoritedBreed)))
        }
        
        @Test func favoriteActionDebouncing() async throws {
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let unfavoritedBreed = CatBreed.mockAbyssinian

            let core = try await makeTestCore(insert: [favoritedBreed])
                        
            let store = TestStore(initialState: FavoritesFeature.State()) {
                FavoritesFeature()
            } withDependencies: {
                $0.date.now = favoritedDate
                $0.catGateway = core.managers.catGateway
            }
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.browsingModeState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded([favoritedBreed]), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed]))
            }

            // Send multiple rapid favorite/unfavorite actions
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: false))

            // Only the last action should execute after debounce
            await store.receive(.unfavoriteActionSucceeded(catBreed: unfavoritedBreed), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: []))
            }
            
            // Verify broadcast was sent
            await store.receive(.broadcast(.favoritesFeatureUnfavorited(breed: unfavoritedBreed)))
        }
        
        @Test func favoriteActionFromOutsideMatchingBreed() async throws {
            
            let favoritedDate = Date()
            let favoritedBreed1 = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let favoritedBreed2 = CatBreed.make(from: .mockAegean, favorited: favoritedDate)
            let unfavoritedBreed = CatBreed.mockAbyssinian

            let core = try await makeTestCore(insert: [favoritedBreed1])
                        
            let store = TestStore(initialState: FavoritesFeature.State()) {
                FavoritesFeature()
            } withDependencies: {
                $0.date.now = favoritedDate
                $0.catGateway = core.managers.catGateway
            }
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.browsingModeState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded([favoritedBreed1]), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed1]))
            }

            // Send action from outside with matching breed
            await store.send(.favoriteActionFromOutside(catBreed: favoritedBreed2, newDesiredState: true)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed1, favoritedBreed2]))
            }
            
            // Send action from outside with matching breed
            await store.send(.favoriteActionFromOutside(catBreed: unfavoritedBreed, newDesiredState: false)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed2]))
            }
        }
        
        @Test func completeLifecycle() async throws {
            
            let favoritedDate = Date()
            let offsetCounter = OffsetCounter()

            let favoritedBreed1 = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let favoritedBreed2 = CatBreed.make(from: .mockAegean, favorited: favoritedDate.addingTimeInterval(1.0))
            let unfavoritedBreed1 = CatBreed.mockAbyssinian
            let unfavoritedBreed2 = CatBreed.mockAegean

            let core = try await makeTestCore(insert: [favoritedBreed1, favoritedBreed2])
                        
            let store = TestStore(initialState: FavoritesFeature.State()) {
                FavoritesFeature()
            } withDependencies: {
                $0.date = DateGenerator {
                    favoritedDate.addingTimeInterval(offsetCounter.nextOffset())
                }
                $0.catGateway = core.managers.catGateway
            }
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
                $0.browsingModeState = .bootstrapping
            }
            
            await store.receive(.bootstrappingSucceeded([favoritedBreed2, favoritedBreed1]), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed2, favoritedBreed1]))
            }

            await store.send(.favoriteAction(catBreed: favoritedBreed1, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: favoritedBreed2, newDesiredState: false))
            
            await store.receive(.unfavoriteActionSucceeded(catBreed: unfavoritedBreed2), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: [favoritedBreed1]))
            }
            
            await store.receive(.broadcast(.favoritesFeatureUnfavorited(breed: unfavoritedBreed2)))
            
            await store.send(.favoriteAction(catBreed: favoritedBreed1, newDesiredState: false))
            
            await store.receive(.unfavoriteActionSucceeded(catBreed: unfavoritedBreed1), timeout: .seconds(1)) {
                $0.browsingModeState = .ready(breeds: IdentifiedArray(uniqueElements: []))
            }
            
            await store.receive(.broadcast(.favoritesFeatureUnfavorited(breed: unfavoritedBreed1)))
        }
    }
}
