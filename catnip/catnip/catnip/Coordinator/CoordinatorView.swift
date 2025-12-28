//
//  CoordinatorView.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import ComposableArchitecture
import SwiftUI
import CatsKitDomain

struct CoordinatorView: View {

    @Namespace var namespace

    @Bindable var store: StoreOf<CoordinatorFeature>

    var body: some View {

        TabView {

            Tab {
                homeNavigationStack {
                    HomeView(store: store.scope(state: \.home,
                                                action: \.home),
                             namespace: namespace)
                }
            } label: {
                Label(L10n.homeTabName.localized, systemImage: Constants.listIcon)
            }

            Tab {
                favoritesNavigationStack {
                    FavoritesView(store: store.scope(state: \.favorites,
                                                     action: \.favorites))
                }
            } label: {
                Label(L10n.favoriteTabName.localized, systemImage: Constants.favoriteIcon)
            }
        }
        .tint(store.tabTintColor)
        .onAppear { store.send(.onAppear) }
    }
}

private extension CoordinatorView {

    enum Constants {

        static let listIcon: String = "infinity"
        static let favoriteIcon: String = "star.fill"
    }
}

private extension CoordinatorView {

    @ViewBuilder
    func homeNavigationStack<Content: View>(@ViewBuilder content: () -> Content) -> some View {

        NavigationStack(path: $store.scope(state: \.homePath,
                                           action: \.homePath)) { content() }
        destination: { destinationView(for: $0) }
    }

    @ViewBuilder
    func favoritesNavigationStack<Content: View>(@ViewBuilder content: () -> Content) -> some View {

        NavigationStack(path: $store.scope(state: \.favoritesPath,
                                           action: \.favoritesPath)) { content() }
        destination: { destinationView(for: $0) }
    }

    @ViewBuilder
    func destinationView(for state: Store<Path.State, Path.Action>) -> some View {

        switch state.case {

        default: Text("")
        }
    }
}
