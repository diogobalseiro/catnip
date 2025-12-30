//
//  DetailFeatureTests.swift
//  catnip
//
//  Created by Diogo Balseiro on 28/12/2025.
//

import Testing
@testable import catnip
import ComposableArchitecture
import CatsKitDomain
import Foundation
import CatsKitDomainStaging

extension FeatureTests {
    
    @Suite("DetailFeature")
    @MainActor
    struct DetailFeatureTests {
        
        /// Tests that the onAppear action correctly sets the appeared flag on first appearance.
        ///
        /// This test verifies:
        /// - The appeared flag starts as false
        /// - After sending onAppear, the appeared flag becomes true
        /// - No effects are triggered
        @Test func onAppear() async throws {
            
            let core = try await makeTestCore()
            
            let store = TestStore(initialState: DetailFeature.State(catBreed: .mockAbyssinian)) {
                DetailFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Verify initial state
            #expect(store.state.appeared == false)
            
            // Send onAppear action
            await store.send(.onAppear) {
                $0.appeared = true
            }
        }
        
        /// Tests the successful flow of favoriting a cat breed.
        ///
        /// This test verifies:
        /// 1. Favoriting action is triggered with the correct parameters
        /// 2. The gateway successfully marks the breed as favorited
        /// 3. The state is updated with the favorited breed
        /// 4. A broadcast action is sent to notify other features
        @Test func favoriteActionSuccess() async throws {
            
            let core = try await makeTestCore(insert: [.mockAbyssinian])
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            
            let store = TestStore(initialState: DetailFeature.State(catBreed: .mockAbyssinian)) {
                DetailFeature()
            } withDependencies: {
                $0.date.now = favoritedDate
                $0.catGateway = core.managers.catGateway
            }
            
            // Send favorite action
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: true))
            
            // Wait for debounce (0.5 seconds) and verify success action
            await store.receive(.favoriteActionSucceeded(catBreed: favoritedBreed), timeout: .seconds(1)) {
                $0.catBreed = favoritedBreed
            }
            
            // Verify broadcast was sent
            await store.receive(.broadcast(.detailFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true)))
        }
        
        /// Tests the successful flow of unfavoriting a cat breed.
        ///
        /// This test verifies:
        /// 1. Unfavoriting action is triggered with the correct parameters
        /// 2. The gateway successfully removes the favorite status
        /// 3. The state is updated with the unfavorited breed
        /// 4. A broadcast action is sent to notify other features
        @Test func unfavoriteActionSuccess() async throws {
            
            let core = try await makeTestCore(insert: [.mockAbyssinian])
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let unfavoritedBreed = CatBreed.mockAbyssinian
            
            let store = TestStore(initialState: DetailFeature.State(catBreed: favoritedBreed)) {
                DetailFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Send unfavorite action
            await store.send(.favoriteAction(catBreed: favoritedBreed, newDesiredState: false))
            
            // Wait for debounce and verify success action
            await store.receive(.favoriteActionSucceeded(catBreed: unfavoritedBreed), timeout: .seconds(1)) {
                $0.catBreed = unfavoritedBreed
            }
            
            // Verify broadcast was sent
            await store.receive(.broadcast(.detailFeatureFavoriteAction(breed: unfavoritedBreed, newDesiredState: false)))
        }
        
        /// Tests the debouncing behavior of the favorite action.
        ///
        /// This test verifies:
        /// 1. Multiple rapid favorite actions are sent
        /// 2. Only the last action is executed due to debouncing
        /// 3. Earlier actions are cancelled
        @Test func favoriteActionDebouncing() async throws {
            
            let core = try await makeTestCore(insert: [.mockAbyssinian])
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            
            let store = TestStore(initialState: DetailFeature.State(catBreed: .mockAbyssinian)) {
                DetailFeature()
            } withDependencies: {
                $0.date.now = favoritedDate
                $0.catGateway = core.managers.catGateway
            }
            
            // Send multiple rapid favorite/unfavorite actions
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: true))
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: false))
            await store.send(.favoriteAction(catBreed: .mockAbyssinian, newDesiredState: true))
            
            // Only the last action should execute after debounce
            await store.receive(.favoriteActionSucceeded(catBreed: favoritedBreed), timeout: .seconds(1)) {
                $0.catBreed = favoritedBreed
            }
            
            await store.receive(.broadcast(.detailFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true)))
        }
        
        /// Tests handling favorite actions from outside sources (e.g., other features).
        ///
        /// This test verifies:
        /// 1. When a matching breed is updated elsewhere, this feature updates its state
        /// 2. The state is synchronized with the external change
        @Test func favoriteActionFromOutsideMatchingBreed() async throws {
            
            let core = try await makeTestCore(insert: [.mockAbyssinian])
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            
            let store = TestStore(initialState: DetailFeature.State(catBreed: .mockAbyssinian)) {
                DetailFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Send action from outside with matching breed
            await store.send(.favoriteActionFromOutside(catBreed: favoritedBreed)) {
                $0.catBreed = favoritedBreed
            }
        }
        
        /// Tests that favorite actions from outside are ignored for non-matching breeds.
        ///
        /// This test verifies:
        /// 1. When a different breed is updated elsewhere, this feature ignores it
        /// 2. The state remains unchanged
        @Test func favoriteActionFromOutsideNonMatchingBreed() async throws {
            
            let core = try await makeTestCore(insert: [.mockAbyssinian, .mockAegean])
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAegean, favorited: favoritedDate)
            
            let catBreed = CatBreed.mockAbyssinian
            let store = TestStore(initialState: DetailFeature.State(catBreed: catBreed)) {
                DetailFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Send action from outside with different breed
            await store.send(.favoriteActionFromOutside(catBreed: favoritedBreed))
            
            // Verify state was NOT updated (still Abyssinian, not Aegean)
            #expect(store.state.catBreed.id == catBreed.id)
            #expect(store.state.catBreed.favorited == nil)
        }
        
        /// Tests that broadcast actions complete without side effects.
        ///
        /// This test verifies:
        /// 1. Broadcast actions can be received
        /// 2. They don't modify state or trigger effects
        @Test func broadcastAction() async throws {
            
            let core = try await makeTestCore(insert: [.mockAbyssinian])
            
            let catBreed = CatBreed.mockAbyssinian
            
            let store = TestStore(initialState: DetailFeature.State(catBreed: catBreed)) {
                DetailFeature()
            } withDependencies: {
                $0.catGateway = core.managers.catGateway
            }
            
            // Send broadcast action
            await store.send(.broadcast(.detailFeatureFavoriteAction(breed: catBreed, newDesiredState: true)))
            
            // Verify no state changes occurred
            #expect(store.state.catBreed.id == catBreed.id)
        }
        
        /// Tests the complete lifecycle of a detail view.
        ///
        /// This test verifies the typical user journey:
        /// 1. View appears (onAppear)
        /// 2. User favorites the breed
        /// 3. State updates accordingly
        @Test func completeLifecycle() async throws {
            
            let core = try await makeTestCore(insert: [.mockAbyssinian])
            
            let favoritedDate = Date()
            let favoritedBreed = CatBreed.make(from: .mockAbyssinian, favorited: favoritedDate)
            let catBreed = CatBreed.mockAbyssinian
            
            let store = TestStore(initialState: DetailFeature.State(catBreed: catBreed)) {
                DetailFeature()
            } withDependencies: {
                $0.date.now = favoritedDate
                $0.catGateway = core.managers.catGateway
            }
            
            // Step 1: View appears
            await store.send(.onAppear) {
                $0.appeared = true
            }
            
            // Step 2: User favorites the breed
            await store.send(.favoriteAction(catBreed: catBreed, newDesiredState: true))
            
            // Step 3: Favorite succeeds
            await store.receive(.favoriteActionSucceeded(catBreed: favoritedBreed), timeout: .seconds(1)) {
                $0.catBreed = favoritedBreed
            }
            
            // Step 4: Broadcast is sent
            await store.receive(.broadcast(.detailFeatureFavoriteAction(breed: favoritedBreed, newDesiredState: true)))
            
            // Verify final state
            #expect(store.state.appeared == true)
            #expect(store.state.catBreed.id == CatBreed.mockAbyssinian.id)
            #expect(store.state.catBreed.favorited == favoritedDate)
        }
    }
}
