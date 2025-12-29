//
//  CoordinatorFeature.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import CatsKitDomain
import Combine
import os

@Reducer
struct CoordinatorFeature {

    @Dependency(\.reachability) var reachability

    @ObservableState
    struct State: Equatable {

        var appeared = false

        var home = HomeFeature.State()
        var favorites = FavoritesFeature.State()

        var homePath = StackState<Path.State>()
        var favoritesPath = StackState<Path.State>()
        
        var connected = true
        var tabTintColor: Color {
            connected ? .accent : .red
        }
    }

    enum Action {

        case home(HomeFeature.Action)
        case favorites(FavoritesFeature.Action)

        case homePath(StackAction<Path.State, Path.Action>)
        case favoritesPath(StackAction<Path.State, Path.Action>)
        
        case onAppear
        case reachabilityChanged(Bool)
    }
  
    nonisolated enum CancelID: Equatable, Hashable, Sendable {

        case reachability
    }

    var body: some Reducer<State, Action> {

        Scope(state: \.home, action: \.home) { HomeFeature() }
        Scope(state: \.favorites, action: \.favorites) { FavoritesFeature() }

        Reduce { state, action in

            switch action {
            
            case .onAppear:
                handleOnAppear(state: &state)

            case let .home(.breedTapped(breed)):
                handleBreedDetailNavigation(breed: breed,
                                            path: &state.homePath)

            case let .favorites(.breedTapped(breed)):
                handleBreedDetailNavigation(breed: breed,
                                            path: &state.favoritesPath)

            case let .favorites(.broadcast(.favoritesFeatureUnfavorited(breed))):
                handleFavoritesBroadcastUnfavoritedAction(breed: breed,
                                                          state: &state)


            case let .home(.broadcast(.homeFeatureFavoriteAction(breed, newDesiredState))):
                handleHomeBroadcastFavoritedAction(breed: breed,
                                                   newDesiredState: newDesiredState,
                                                   state: &state)

            case let .homePath(.element(id: _,
                                        action: .detail(.broadcast(.detailFeatureFavoriteAction(breed, newDesiredState))))):
                handleDetailBroadcastFavoritedAction(breed: breed,
                                                     newDesiredState: newDesiredState,
                                                     state: &state)

            case let .favoritesPath(.element(id: _, action: .detail(.broadcast(.detailFeatureFavoriteAction(breed, newDesiredState))))):
                handleDetailBroadcastFavoritedAction(breed: breed,
                                                     newDesiredState: newDesiredState,
                                                     state: &state)
            
            case let .reachabilityChanged(isConnected):
                handleReachabilityChange(connected: isConnected, state: &state)

            case .home,
                    .favorites,
                    .homePath,
                    .favoritesPath:
                    .none
            }
        }
        .forEach(\.homePath, action: \.homePath)
        .forEach(\.favoritesPath, action: \.favoritesPath)
    }
}

@Reducer
enum Path {

    case detail(DetailFeature)
}

extension Path.State: Equatable {}

private extension CoordinatorFeature {

    func handleOnAppear(state: inout State) -> Effect<Action> {

        guard state.appeared == false else {
            
            return .none
        }

        Logger.shared.debug("Appeared")

        state.appeared = true
        state.connected = reachability.isConnected
        
        return .publisher {
            reachability.isConnectedPublisher
                .map { Action.reachabilityChanged($0) }
        }
        .cancellable(id: CancelID.reachability)
    }

    func handleFavoritesBroadcastUnfavoritedAction(breed: CatBreed,
                                                   state: inout State) -> Effect<Action> {

        // Send the event to:
        // * the home feature
        // * the home path's features and the favorite path's features
        return .merge(
            [.send(.home(.favoriteActionFromOutside(catBreed: breed)))]
            + favoriteActionFromOutsideEffectsForAllPaths(state: &state,
                                                          breed: breed))
    }

    func handleHomeBroadcastFavoritedAction(breed: CatBreed,
                                            newDesiredState: Bool,
                                            state: inout State) -> Effect<Action> {
        // Send the event to:
        // * the favorite feature
        // * the home path's features and the favorite path's features
        return .merge(
            [.send(.favorites(.favoriteActionFromOutside(catBreed: breed,
                                                         newDesiredState: newDesiredState)))]
            + favoriteActionFromOutsideEffectsForAllPaths(state: &state,
                                                          breed: breed))
    }

    func handleDetailBroadcastFavoritedAction(breed: CatBreed,
                                              newDesiredState: Bool,
                                              state: inout State) -> Effect<Action> {

        // Send the event to:
        // * the home feature
        // * the favorite feature
        // * the home path's features and the favorite path's features
        return .merge(
            [.send(.home(.favoriteActionFromOutside(catBreed: breed))),
             .send(.favorites(.favoriteActionFromOutside(catBreed: breed,
                                                         newDesiredState: newDesiredState)))]
            + favoriteActionFromOutsideEffectsForAllPaths(state: &state,
                                                          breed: breed))
    }

    func favoriteActionFromOutsideEffectsForAllPaths(state: inout State,
                                                     breed: CatBreed) -> [Effect<Action>] {

        state.homePath.ids
            .map { .send(.homePath(.element(id: $0,
                                            action: .detail(.favoriteActionFromOutside(catBreed: breed))))) }
        +
        state.favoritesPath.ids
            .map { .send(.favoritesPath(.element(id: $0,
                                                 action: .detail(.favoriteActionFromOutside(catBreed: breed))))) }
    }

    func handleReachabilityChange(connected: Bool,
                                  state: inout State) -> Effect<Action> {

        Logger.shared.debug("Reachability is now \(connected ? "on" : "off")")

        state.connected = connected
        return .none
    }

    func handleBreedDetailNavigation(breed: CatBreed,
                                     path: inout StackState<Path.State>) -> Effect<Action> {

        path.append(.detail(DetailFeature.State(catBreed: breed)))
        return .none
    }
}
