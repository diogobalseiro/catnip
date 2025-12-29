//
//  DetailView.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import SwiftUI
import ComposableArchitecture
import CatsKitDomain
import CatsKitDomainStaging

struct DetailView: View {

    @Bindable var store: StoreOf<DetailFeature>

    let isFavoriteCoreState: Bool
    @State private var isFavoriteUIState: Bool = false
    @State private var availableWidth: CGFloat = 0.0

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 0) {

                image

                VStack(alignment: .leading) {
                    header
                        .padding(.top, Constants.WholeView.paddingTop)
                        .padding(.bottom, Constants.WholeView.paddingBottom)
                    metadata
                }
                .padding(.horizontal)
                .background(Color(.systemBackground))
            }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { availableWidth = $0 }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            isFavoriteUIState = isFavoriteCoreState
        }
        .onChange(of: isFavoriteCoreState) { oldValue, newValue in
            isFavoriteUIState = newValue
        }
    }
}

private extension DetailView {

    @ViewBuilder
    var image: some View {

        CachedImage(desiredURL: URL(possibleString: store.state.catBreed.imageURL),
                    animation: .bouncy(duration: Constants.Image.transitionDuration))
        .scaledToFill()
        .frame(width: availableWidth, height: Constants.Image.height)
        .clipped()
        .shadow(color: .black.opacity(Constants.Image.shadowOpacity),
                radius: Constants.Image.shadowRadius,
                x: Constants.Image.shadowX,
                y: Constants.Image.shadowY)
    }

    @ViewBuilder
    var header: some View {

        HStack {

            Text(store.state.catBreed.name)
                .font(.title)
                .bold()

            Spacer()

            Button(action: {
                isFavoriteUIState.toggle()
                store.send(.favoriteAction(catBreed: store.state.catBreed,
                                           newDesiredState: isFavoriteUIState))
            }) {

                Image(systemName: isFavoriteUIState ? Constants.Favorite.favorited : Constants.Favorite.unfavorited)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.Favorite.size, height: Constants.Favorite.size)
                    .foregroundStyle(isFavoriteUIState ? .accent : .white)
                    .padding(Constants.Favorite.padding)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .fill(isFavoriteUIState ? .accent.opacity(Constants.Favorite.backgroundOpacity) : .clear)
                            )
                    )
                    .shadow(color: .black.opacity(Constants.Favorite.shadowOpacity),
                            radius: Constants.Favorite.shadowRadius,
                            x: Constants.Favorite.shadowX,
                            y: Constants.Favorite.shadowY)
            }
            .buttonStyle(.plain)
            .background(Circle().fill(.ultraThinMaterial))
            .shadow(color: .black.opacity(Constants.Header.shadowOpacity),
                    radius: Constants.Header.shadowRadius,
                    x: Constants.Header.shadowX,
                    y: Constants.Header.shadowY)
            .contentShape(Circle())
            .padding(Constants.Header.padding)
            .accessibilityIdentifier("DetailFavoriteButton")
        }
    }

    @ViewBuilder
    var metadata: some View {

        VStack(alignment: .leading,
               spacing: Constants.Metadata.outerSpacing) {
            VStack(alignment: .leading,
                   spacing: Constants.Metadata.innerSpacing) {
                Text(L10n.detailTemperament.localized.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                Text(store.state.catBreed.temperament)
                    .font(.body)
            }

            VStack(alignment: .leading,
                   spacing: Constants.Metadata.innerSpacing) {
                Text(L10n.detailOrigin.localized.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                Text(store.state.catBreed.origin)
                    .font(.body)
            }

            VStack(alignment: .leading,
                   spacing: Constants.Metadata.innerSpacing) {
                Text(L10n.detailLifespan.localized.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                Text(store.state.catBreed.lifeSpan)
                    .font(.body)
            }

            VStack(alignment: .leading,
                   spacing: Constants.Metadata.innerSpacing) {
                Text(L10n.detailDescription.localized.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                Text(store.state.catBreed.catDescription)
                    .font(.body)
            }
        }
               .padding(.bottom, Constants.Metadata.padding)
    }
}

private extension DetailView {

    enum Constants {

        enum WholeView {

            static let paddingTop = 20.0
            static let paddingBottom = 12.0
        }

        enum Image {

            static let transitionDuration = 0.3
            static let height = 450.0
            static let shadowOpacity = 0.1
            static let shadowRadius = 12.0
            static let shadowX = 0.0
            static let shadowY = 4.0
        }
        
        enum Favorite {

            static let favorited = "star.fill"
            static let unfavorited = "star"
            static let size = 32.0
            static let padding = 6.0
            static let backgroundOpacity = 0.2
            static let shadowOpacity = 0.2
            static let shadowRadius = 6.0
            static let shadowX = 0.0
            static let shadowY = 3.0
        }
        
        enum Header {
            
            static let padding = 4.0
            static let shadowOpacity = 0.1
            static let shadowRadius = 6.0
            static let shadowX = 0.0
            static let shadowY = 2.0
        }
        
        enum Metadata {
            
            static let outerSpacing = 20.0
            static let innerSpacing = 4.0
            static let padding = 24.0
        }
    }
}

#Preview {

    let cat = CatBreed.mockAegean

    DetailView(
        store: Store(initialState: DetailFeature.State(catBreed: cat),
                     reducer: { DetailFeature() }) {
                         $0.core = Core.testValue
                     },
        isFavoriteCoreState: cat.favorited != nil
    )
}
