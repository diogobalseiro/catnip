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

@Reducer
struct FavoritesFeature {

    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {}

    var body: some Reducer<State, Action> {

        Reduce { state, action in

            return .none
        }
    }
}
