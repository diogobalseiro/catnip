//
//  HomeView.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import SwiftUI
import ComposableArchitecture
import CatsKitDomain

struct HomeView: View {

    @Bindable var store: StoreOf<HomeFeature>

    @State private var availableWidth: CGFloat = 0.0
    let namespace: Namespace.ID

    @ViewBuilder
    var body: some View {

        contentView
    }

    @ViewBuilder
    var contentView: some View {

        VStack {

            switch store.state.visualState {

            case .idle:
                idleView

            case .bootstrapping:
                bootstrappingView

            case .ready:
                readyView
            }
        }
        .navigationTitle(L10n.homeTitle.localized)
        .navigationBarTitleDisplayMode(.large)
        .onAppear { store.send(.onAppear) }
    }
}

private extension HomeView {

    @ViewBuilder
    var idleView: some View {

        HStack {
            Spacer()
            Image(systemName: Constants.Idle.systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.accent)
                .frame(width: Constants.Idle.size)
                .opacity(Constants.Idle.opacity)
                .padding()
                .onTapGesture {
                    store.send(.onAppear)
                }
            Spacer()
        }
    }

    @ViewBuilder
    var bootstrappingView: some View {

        ProgressView()
            .tint(.accent)
    }

    @ViewBuilder
    var readyView: some View {

        list(breeds: store.state.breeds,
             workingOnNewPage: store.state.browsingModeState.workingOnNewPage)
    }

    @ViewBuilder
    func list(breeds: [CatBreed],
              workingOnNewPage: Bool) -> some View {

        ScrollView {

            LazyVGrid(columns: Constants.Grid.columns,
                      spacing: Constants.Grid.verticalSpacing) {

                ForEach(Array(breeds.enumerated()),
                        id: \.element.id) { index, item in

                    ListItemView(catBreed: item,
                                 isFavoriteCoreState: item.favorited != nil,
                                 layoutGuidance: layoutGuidance(index: index)) { newDesiredState in

                        store.send(.favoriteAction(catBreed: item, newDesiredState: newDesiredState))
                    }
                                 .id(item.id)
                                 .onAppear { store.send(.fetchPageIfNeeded(index: index)) }
                                 .onTapGesture { store.send(.breedTapped(item)) }
                                 .matchedTransitionSource(id: "catbreed-\(item.id)", in: namespace)
                }
            }
                      .padding(Constants.Grid.horizontalSpacing)
                      .onGeometryChange(for: CGFloat.self) { proxy in
                          proxy.size.width
                      } action: { availableWidth = $0 }

            if workingOnNewPage {

                ProgressView()
                    .tint(.accent)
            }
        }
        .accessibilityIdentifier("HomeScrollView")
        .searchable(text: $store.searchText,
                    isPresented: $store.isSearching,
                    placement: .automatic,
                    prompt: L10n.homeSearchPlaceholder.localized)
        .scrollDismissesKeyboard(.interactively)
    }

    func layoutGuidance(index: Int) -> ListItemView.LayoutGuidance {

        .init(favoriteAlignment: index % 2 == 0 ? .bottomLeading : .bottomTrailing,
              availableWidth: listItemViewIdealWidth)
    }

    var listItemViewIdealWidth: CGFloat {

        max(0,(availableWidth - Constants.Grid.horizontalSpacing * 3) / Double(Constants.Grid.columns.count))
    }

    enum Constants {

        enum Grid {

            static let horizontalSpacing = 16.0
            static let verticalSpacing = 16.0
            static let columns: [GridItem] = [
                GridItem(.flexible(), spacing: horizontalSpacing),
                GridItem(.flexible(), spacing: horizontalSpacing)
            ]
        }
        
        enum Idle {
            
            static let systemName = "cat"
            static let size = 60.0
            static let opacity = 0.4
        }
    }
}

#Preview {

    @Previewable @Namespace var namespace

    HomeView(
        store: Store(initialState: HomeFeature.State(),
                     reducer: { HomeFeature() }) {
            $0.core = Core.testValue
                     },
        namespace: namespace
    )
}
