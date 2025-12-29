//
//  DetailFeature.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import CatsKitDomain
import os

@Reducer
struct DetailFeature {

    @Dependency(\.catGateway) var catGateway
    @Dependency(\.date) var date

    nonisolated enum CancelID: Equatable, Hashable, Sendable {

        case favoriteDebounce(String)
    }

    @ObservableState
    struct State: Equatable {

        var catBreed: CatBreed

        var appeared = false
    }

    enum Action: Equatable {

        case onAppear
        case favoriteAction(catBreed: CatBreed, newDesiredState: Bool)
        case favoriteActionSucceeded(catBreed: CatBreed)
        case favoriteActionFailed(catBreed: CatBreed)
        case favoriteActionFromOutside(catBreed: CatBreed)

        case broadcast(Broadcast)
        enum Broadcast: Equatable {

            case detailFeatureFavoriteAction(breed: CatBreed, newDesiredState: Bool)
        }
    }

    var body: some Reducer<State, Action> {

        Reduce { state, action in

            switch action {

            case .onAppear:
                handleOnAppear(state: &state)

            case let .favoriteAction(catBreed: catBreed, newDesiredState: newDesiredState):
                handleFavoriteAction(catBreed: catBreed, newDesiredState: newDesiredState, state: &state)

            case let .favoriteActionSucceeded(catBreed),
                let .favoriteActionFailed(catBreed):
                handleFavoriteActionResult(catBreed: catBreed, state: &state)

            case let .favoriteActionFromOutside(catBreed):
                handleFavoriteActionFromOutside(catBreed: catBreed, state: &state)

            case let .broadcast(action):
                handleBroadcast(action: action, state: &state)
            }
        }
    }
}

private extension DetailFeature {

    func handleOnAppear(state: inout State) -> Effect<Action> {

        /// DidLoad analogue
        guard state.appeared == false else {
            return .none
        }

        state.appeared = true

        return .none
    }

    func handleFavoriteAction(catBreed: CatBreed,
                              newDesiredState: Bool,
                              state: inout State) -> Effect<Action> {

        Logger.shared.debug("Favorited action tapped: \(catBreed.name) -> \(newDesiredState)")

        return .run { send in

            Logger.shared.debug("Favorited action will work: \(catBreed.name) -> \(newDesiredState)")

            do {

                let newCatItem: CatBreed

                if newDesiredState {

                    newCatItem = try await catGateway.favoriteBreed(catBreed, favoritedAt: date.now)

                } else {

                    newCatItem = try await catGateway.unfavoriteBreed(catBreed)
                }

                await send(.favoriteActionSucceeded(catBreed: newCatItem))
                await send(.broadcast(.detailFeatureFavoriteAction(breed: newCatItem, newDesiredState: newDesiredState)))

            } catch {

                await send(.favoriteActionFailed(catBreed: catBreed))
            }
        }
        .debounce(id: CancelID.favoriteDebounce(state.catBreed.id),
                  for: 0.5,
                  scheduler: DispatchQueue.main)
    }

    func handleFavoriteActionResult(catBreed: CatBreed,
                                    state: inout State) -> Effect<Action> {

        state.catBreed = catBreed

        return .none
    }

    func handleFavoriteActionFromOutside(catBreed: CatBreed,
                                         state: inout State) -> Effect<Action> {

        Logger.shared.debug("Handle favorite action from outside: \(catBreed.name)")

        guard state.catBreed.id == catBreed.id else {

            Logger.shared.debug("No need to update state, as it's a different cat")
            return .none
        }

        state.catBreed = catBreed

        return .none
    }

    func handleBroadcast(action: Action.Broadcast,
                         state: inout State) -> Effect<Action> {

        return .none
    }
}
