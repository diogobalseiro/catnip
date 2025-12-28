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
enum Path {}

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

    func handleReachabilityChange(connected: Bool,
                                  state: inout State) -> Effect<Action> {

        Logger.shared.debug("Reachability is now \(connected ? "on" : "off")")

        state.connected = connected
        return .none
    }
}
