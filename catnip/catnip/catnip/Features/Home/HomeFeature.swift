//
//  HomeFeature.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import ComposableArchitecture
import CatsKitDomain
import os

@Reducer
struct HomeFeature {

    @Dependency(\.catGateway) var catGateway
    @Dependency(\.environment) var environment
    @Dependency(\.date) var date

    enum VisualState: Equatable, Hashable {

        case idle
        case bootstrapping
        case ready
    }

    struct BrowsingModeState: Equatable, Hashable {

        var breeds = IdentifiedArrayOf<CatBreed>()
        var workingOnNewPage: Bool = false
    }

    struct SearchingModeState: Equatable, Hashable {

        var query: String?
        var breeds = IdentifiedArrayOf<CatBreed>()
        var workingOnNewQuery = false
    }

    nonisolated enum CancelID: Equatable, Hashable, Sendable {

        case favoriteDebounce(String)
        case fetchPageThrottle
        case searchDebounce
        case searchCancel
    }

    @ObservableState
    struct State: Equatable {

        var appeared = false

        var visualState = VisualState.idle
        var browsingModeState = BrowsingModeState()
        var searchingModeState = SearchingModeState()

        var searchText = ""
        var isSearching = false

        var breeds: [CatBreed] {

            isSearching
            ? searchingModeState.breeds.elements
            : browsingModeState.breeds.elements
        }
    }

    enum Action: Equatable, BindableAction {

        case onAppear
        case bootstrappingFailed
        case bootstrappingSucceeded([CatBreed])

        case fetchPageIfNeeded(index: Int)
        case fetchPageSucceeded(newBreeds: [CatBreed])
        case fetchPageFailed

        case favoriteAction(catBreed: CatBreed, newDesiredState: Bool)
        case favoriteActionSucceeded(catBreed: CatBreed)
        case favoriteActionFailed(catBreed: CatBreed)
        case favoriteActionFromOutside(catBreed: CatBreed)

        case broadcast(Broadcast)
        enum Broadcast: Equatable {

            case homeFeatureFavoriteAction(breed: CatBreed, newDesiredState: Bool)
        }

        case breedTapped(CatBreed)

        case binding(BindingAction<State>)

        case searchBreeds(String)
        case searchBreedsSucceeded([CatBreed])
        case searchBreedsFailed
    }

    var body: some Reducer<State, Action> {

        BindingReducer()

        Reduce { state, action in

            switch action {

            case .onAppear:
                handleOnAppear(state: &state)

            case let .bootstrappingSucceeded(breeds):
                handleBootstrappingSucceeded(breeds: breeds, state: &state)

            case .bootstrappingFailed:
                handleBootstrappingFailed(state: &state)

            case let .fetchPageIfNeeded(index):
                handleFetchPageIfNeeded(index: index, state: &state)

            case let .fetchPageSucceeded(newBreeds):
                handleFetchPageSucceeded(newBreeds: newBreeds, state: &state)

            case .fetchPageFailed:
                handleFetchPageFailed(state: &state)

            case let .favoriteAction(catBreed, newDesiredState):
                handleFavoriteAction(catBreed: catBreed, newDesiredState: newDesiredState, state: &state)

            case let .favoriteActionSucceeded(catBreed),
                let .favoriteActionFailed(catBreed):
                handleFavoriteActionResult(catBreed: catBreed, state: &state)

            case let .favoriteActionFromOutside(catBreed):
                handleFavoriteActionFromOutside(catBreed: catBreed, state: &state)

            case let .broadcast(action):
                handleBroadcast(action: action, state: &state)

            case .breedTapped:
                handleBreedTapped(state: &state)

            case let .binding(action):
                handleBinding(binding: action, state: &state)

            case let .searchBreeds(query):
                handleSearchBreeds(query: query, state: &state)

            case let .searchBreedsSucceeded(results):
                handleSearchBreedsSucceeded(results: results, state: &state)

            case .searchBreedsFailed:
                handleSearchBreedsFailed(state: &state)
            }
        }
    }
}

private extension HomeFeature {

    var fetchBreedsLimit: Int {

        environment == .live ? 20 : 10
    }

    func handleOnAppear(state: inout State) -> Effect<Action> {

        Logger.shared.debug("Appeared")

        guard state.appeared == false,
                state.visualState == .idle else {
            return .none
        }

        state.appeared = true
        state.visualState = .bootstrapping

        return .run(priority: .high,
                    name: "Bootstrapping") { send in

            let breeds = try await catGateway.breeds(offset: 0, limit: fetchBreedsLimit)

            guard breeds.isEmpty == false else {

                Logger.shared.debug("Failed to bootstrap")
                await send(.bootstrappingFailed)
                return
            }

            await send(.bootstrappingSucceeded(breeds))

        } catch: { error, send in

            Logger.shared.debug("Failed to bootstrap: \(error)")
            await send(.bootstrappingFailed)
        }
    }

    func handleBootstrappingSucceeded(breeds: [CatBreed],
                                     state: inout State) -> Effect<Action> {

        state.visualState = .ready
        state.browsingModeState = .init(breeds: IdentifiedArrayOf(uniqueElements: breeds),
                                        workingOnNewPage: false)
        return .none
    }

    func handleBootstrappingFailed(state: inout State) -> Effect<Action> {

        state.appeared = false
        state.visualState = .idle
        return .none
    }

    func handleFetchPageIfNeeded(index: Int,
                                 state: inout State) -> Effect<Action> {

        Logger.shared.debug("Showed index: \(index)")

        guard state.isSearching == false,
              state.browsingModeState.workingOnNewPage == false else {

            Logger.shared.debug("Will not fetch new page, already working on one or am searching")
            return .none
        }

        guard index % 2 == 0 else {

            Logger.shared.debug("Showed RHS index, ignoring")
            return .none
        }

        let breeds = state.browsingModeState.breeds
        let diff = breeds.elements.count - index

        guard diff < 6 else {

            Logger.shared.debug("Still have \(diff) elements left, not fetching new page")
            return .none
        }

        Logger.shared.debug("Will fetch a new page, diff \(diff)")

        state.browsingModeState.workingOnNewPage = true

        return .run { send in

            do {

                let newBreeds = try await catGateway.breeds(offset: breeds.elements.count,
                                                            limit: fetchBreedsLimit)

                // If the new page contains no new cats, do we prevent more pages from being pulled?
                // Given we have no control over the API and new cats may be added, allow further fetches
                Logger.shared.debug("Fetched a new page, breeds count: \(newBreeds.count)")

                await send(.fetchPageSucceeded(newBreeds: newBreeds))

            } catch {

                Logger.shared.debug("Failed to fetch a new page")

                await send(.fetchPageFailed)
            }
        }
        .throttle(id: CancelID.fetchPageThrottle,
                  for: 1.0,
                  scheduler: DispatchQueue.main,
                  latest: true)
    }

    func handleFetchPageSucceeded(newBreeds: [CatBreed],
                                  state: inout State) -> Effect<Action> {

        state.browsingModeState.breeds += newBreeds
        state.browsingModeState.workingOnNewPage = false

        return .none
    }

    func handleFetchPageFailed(state: inout State) -> Effect<Action> {

        state.browsingModeState.workingOnNewPage = false

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
                await send(.broadcast(.homeFeatureFavoriteAction(breed: newCatItem, newDesiredState: newDesiredState)))

            } catch {

                await send(.favoriteActionFailed(catBreed: catBreed))
            }
        }
        .debounce(id: CancelID.favoriteDebounce(catBreed.id),
                  for: 0.5,
                  scheduler: DispatchQueue.main)
    }

    func handleFavoriteActionResult(catBreed: CatBreed,
                                    state: inout State) -> Effect<Action> {

        Logger.shared.debug("Handle favorite action from inside: \(catBreed.name)")

        refreshCatOnModeStates(catBreed: catBreed, state: &state)

        return .none
    }

    func handleFavoriteActionFromOutside(catBreed: CatBreed,
                                         state: inout State) -> Effect<Action> {

        Logger.shared.debug("Handle favorite action from outside: \(catBreed.name)")

        refreshCatOnModeStates(catBreed: catBreed, state: &state)

        return .none
    }

    func refreshCatOnModeStates(catBreed: CatBreed,
                                state: inout State) {

        if state.browsingModeState.breeds[id: catBreed.id] != nil {

            state.browsingModeState.breeds[id: catBreed.id] = catBreed
        }

        if state.searchingModeState.breeds[id: catBreed.id] != nil {

            state.searchingModeState.breeds[id: catBreed.id] = catBreed
        }
    }

    func handleBroadcast(action: Action.Broadcast,
                         state: inout State) -> Effect<Action> {

        return .none
    }

    func handleBreedTapped(state: inout State) -> Effect<Action> {

        return .none
    }

    func handleBinding(binding: BindingAction<State>,
                       state: inout State) -> Effect<Action> {

        switch binding {

        case \.searchText:
            handleSearchTerm(state: &state)

        default:
            .none
        }
    }

    func handleSearchTerm(state: inout State) -> Effect<Action> {

        guard state.searchText.count > 2 else {

            return .none
        }
        
        let term = state.searchText

        return .run { send in

            Logger.shared.debug("Search term is '\(term)'")

            await send(.searchBreeds(term))
        }
        .debounce(id: CancelID.searchDebounce,
                  for: 0.3,
                  scheduler: DispatchQueue.main)
    }

    func handleSearchBreeds(query: String, state: inout State) -> Effect<Action> {

        state.searchingModeState.breeds = []
        state.searchingModeState.workingOnNewQuery = true

        return .run { send in

            do {

                let results = try await catGateway.searchBreeds(query: query)

                await send(.searchBreedsSucceeded(results))

            } catch {

                await send(.searchBreedsFailed)
            }
        }
        .cancellable(id: CancelID.searchCancel,
                     cancelInFlight: true)
    }

    func handleSearchBreedsSucceeded(results: [CatBreed], state: inout State) -> Effect<Action> {

        state.searchingModeState.breeds = IdentifiedArray(uniqueElements: results)
        state.searchingModeState.workingOnNewQuery = false

        return .none
    }

    func handleSearchBreedsFailed(state: inout State) -> Effect<Action> {

        state.searchingModeState.workingOnNewQuery = false

        return .none
    }
}
