//
//  FavoritesFeature.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import ComposableArchitecture
import CatsKitDomain
import os
import Combine

@Reducer
struct FavoritesFeature {

    @Dependency(\.catGateway) var catGateway

    enum BrowsingModeState: Equatable, Hashable {

        case idle
        case bootstrapping
        case ready(breeds: IdentifiedArrayOf<CatBreed>)

        var currentBreeds: [CatBreed]? {
            switch self {
            case let .ready(breeds):
                return breeds.elements
            default:
                return nil
            }
        }
    }

    nonisolated enum CancelID: Equatable, Hashable, Sendable {

        case favoriteDebounce(String)
    }

    @ObservableState
    struct State: Equatable {

        var browsingModeState: BrowsingModeState = .idle

        var appeared = false
    }

    enum Action: Equatable {

        case onAppear
        case bootstrappingFailed
        case bootstrappingSucceeded([CatBreed])
        case favoriteAction(catBreed: CatBreed, newDesiredState: Bool)
        case unfavoriteActionSucceeded(catBreed: CatBreed)
        case unfavoriteActionFailed(catBreed: CatBreed)
        case favoriteActionFromOutside(catBreed: CatBreed, newDesiredState: Bool)

        case broadcast(Broadcast)
        enum Broadcast: Equatable {

            case favoritesFeatureUnfavorited(breed: CatBreed)
        }

        case breedTapped(CatBreed)
    }

    var body: some Reducer<State, Action> {

        Reduce { state, action in

            switch action {

            case .onAppear:
                handleOnAppear(state: &state)

            case let .bootstrappingSucceeded(breeds):
                handleBootstrappingSucceeded(breeds: breeds, state: &state)

            case .bootstrappingFailed:
                handleBootstrappingFailed(state: &state)

            case let .favoriteAction(catBreed, newDesiredState):
                handleFavoriteAction(catBreed: catBreed, newDesiredState: newDesiredState, state: &state)

            case let .unfavoriteActionSucceeded(catBreed):
                handleUnfavoriteActionSucceeded(catBreed: catBreed, state: &state)

            case let .unfavoriteActionFailed(catBreed):
                handleUnfavoriteActionFailed(catBreed: catBreed, state: &state)

            case let .favoriteActionFromOutside(catBreed, newDesiredState):
                handleFavoriteActionFromOutside(catBreed: catBreed, newDesiredState: newDesiredState, state: &state)

            case let .broadcast(action):
                handleBroadcast(action: action, state: &state)

            case .breedTapped:
                handleBreedTapped(state: &state)
            }
        }
    }
}

private extension FavoritesFeature {

    enum Constants {
        
        enum Debounce {
            
            static let inactivity:  DispatchQueue.SchedulerTimeType.Stride = 0.5
        }
    }
    
    func handleOnAppear(state: inout State) -> Effect<Action> {

        /// DidLoad analogue
        guard state.appeared == false else {
            return .none
        }

        state.appeared = true
        state.browsingModeState = .bootstrapping

        return .run(priority: .high,
                    name: "Bootstrapping") { send in

            let breeds = try await catGateway.allFavoriteBreeds()
            await send(.bootstrappingSucceeded(breeds))

        } catch: { error, send in

            Logger.shared.debug("Failed to bootstrap: \(error)")
            await send(.bootstrappingFailed)
        }
    }

    func handleBootstrappingSucceeded(breeds: [CatBreed],
                                     state: inout State) -> Effect<Action> {

        state.browsingModeState = .ready(breeds: IdentifiedArrayOf(uniqueElements: breeds))
        return .none
    }

    func handleBootstrappingFailed(state: inout State) -> Effect<Action> {

        state.appeared = false
        return .none
    }

    func handleFavoriteAction(catBreed: CatBreed,
                              newDesiredState: Bool,
                              state: inout State) -> Effect<Action> {

        Logger.shared.debug("Favorited action tapped: \(catBreed.name) -> \(newDesiredState)")

        return .run { send in

            Logger.shared.debug("Favorited action will work: \(catBreed.name) -> \(newDesiredState)")

            do {

                if newDesiredState {

                    Logger.shared.debug("Favorite action ignored")

                } else {

                    let newCatItem = try await catGateway.unfavoriteBreed(catBreed)

                    await send(.unfavoriteActionSucceeded(catBreed: newCatItem))
                    await send(.broadcast(.favoritesFeatureUnfavorited(breed: newCatItem)))
                }

            } catch {

                await send(.unfavoriteActionFailed(catBreed: catBreed))
            }
        }
        .debounce(id: CancelID.favoriteDebounce(catBreed.id),
                  for: Constants.Debounce.inactivity,
                  scheduler: DispatchQueue.main)
    }

    func handleUnfavoriteActionSucceeded(catBreed: CatBreed,
                                         state: inout State) -> Effect<Action> {

        guard case .ready(var breeds) = state.browsingModeState else {

            return .none
        }

        breeds.remove(id: catBreed.id)
        state.browsingModeState = .ready(breeds: breeds)

        return .none
    }

    func handleUnfavoriteActionFailed(catBreed: CatBreed,
                                      state: inout State) -> Effect<Action> {

        guard case .ready(var breeds) = state.browsingModeState else {

            return .none
        }

        breeds[id: catBreed.id] = catBreed
        state.browsingModeState = .ready(breeds: breeds)

        return .none
    }

    func handleFavoriteActionFromOutside(catBreed: CatBreed,
                                         newDesiredState: Bool,
                                         state: inout State) -> Effect<Action> {

        Logger.shared.debug("Handle favorite action from outside: \(catBreed.name)")

        guard case .ready(var breeds) = state.browsingModeState else {

            return .none
        }

        if newDesiredState {

            breeds.updateOrAppend(catBreed)
            let breedsSorted = breeds
                .sorted { ($0.favorited ?? .distantPast) > ($1.favorited ?? .distantPast) }

            state.browsingModeState = .ready(breeds: IdentifiedArrayOf(uniqueElements: breedsSorted))

        } else {

            breeds.remove(id: catBreed.id)
            state.browsingModeState = .ready(breeds: breeds)
        }

        return .none
    }

    func handleBroadcast(action: Action.Broadcast,
                         state: inout State) -> Effect<Action> {

        return .none
    }

    func handleBreedTapped(state: inout State) -> Effect<Action> {

        return .none
    }
}
