//
//  ListItemView.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import SwiftUI
import CatsKitDomain
import CatsKitDomainStaging

struct ListItemView: View {

    struct LayoutGuidance {

        let favoriteAlignment: Alignment
        let availableWidth: CGFloat

        var imageWidth: CGFloat {

            (availableWidth * Constants.Image.widthFactor).rounded(.down)
        }

        var imageHeight: CGFloat {

            (availableWidth * Constants.Image.heightFactor).rounded(.down)
        }

        var width: CGFloat {

            availableWidth
        }

        var height: CGFloat {

            (availableWidth * Constants.WholeView.heightFactor).rounded(.down)
        }
    }

    let catBreed: CatBreed
    let isFavoriteCoreState: Bool
    let layoutGuidance: LayoutGuidance
    let onFavoriteTap: (Bool) -> Void

    @State private var isFavoriteUIState: Bool = false

    var body: some View {

        VStack(alignment: .center, spacing: Constants.WholeView.padding) {

            image
            name
            Spacer()
        }
        .frame(width: layoutGuidance.width,
               height: layoutGuidance.height)
        .contentShape(Rectangle())
        .clipped()
        .accessibilityIdentifier("ListItem_\(catBreed.id)")
        .accessibilityLabel("Cat breed: \(catBreed.name)")
        .accessibilityAddTraits(.isButton)
        .accessibilityElement(children: .contain)
        .onAppear {
            isFavoriteUIState = isFavoriteCoreState
        }
        .onChange(of: isFavoriteCoreState) { oldValue, newValue in
            isFavoriteUIState = newValue
        }
    }

    @ViewBuilder
    var name: some View {

            Text(catBreed.name)
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(Constants.Name.lineLimit)
    }

    @ViewBuilder
    var favorited: some View {

        Button(action: {
            isFavoriteUIState.toggle()
            onFavoriteTap(isFavoriteUIState)
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
                .accessibilityIdentifier("FavoriteButton_\(catBreed.id)")
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityElement()
    }

    @ViewBuilder
    var image: some View {

        CachedImage(desiredURL: URL(possibleString: catBreed.imageURL),
                    animation: .bouncy(duration: Constants.Image.transitionDuration))
        .scaledToFill()
        .frame(width: layoutGuidance.imageWidth, height: layoutGuidance.imageHeight)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: Constants.Image.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Image.cornerRadius)
                .stroke(breedTint(), lineWidth: Constants.Image.borderWidth)
        )
        .shadow(color: .black.opacity(Constants.Image.shadowOpacity),
                radius: Constants.Image.shadowRadius,
                x: Constants.Image.shadowX,
                y: Constants.Image.shadowY)
        .overlay(alignment: layoutGuidance.favoriteAlignment) {
            favorited
        }
        .contentShape(Rectangle())
    }
}

private extension ListItemView {

    enum Constants {

        enum Image {

            static let transitionDuration = 0.3
            static let cornerRadius = 16.0
            static let borderWidth = 2.0
            static let widthFactor = 0.98
            static let heightFactor = 1.2
            static let shadowOpacity = 0.08
            static let shadowRadius = 8.0
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
        
        enum Name {

            static let lineLimit = 1
            static let padding = 5.0
        }

        enum WholeView {

            static let heightFactor = 1.5
            static let padding = 8.0
        }

        enum Other {

            static let tintOpacity = 0.3
        }
    }

    func breedTint(opacity: Double = Constants.Other.tintOpacity) -> Color {

        catBreed.id.lowercased()
            .pastelColor
            .opacity(opacity)
    }
}

#Preview {

    Spacer()
    HStack {

        ListItemView(catBreed: CatBreed.mockAegean,
                     isFavoriteCoreState: false,
                     layoutGuidance: .init(favoriteAlignment: .bottomLeading, availableWidth: 160.0),
                     onFavoriteTap: { newDesiredState in } )
        ListItemView(catBreed: CatBreed.mockAmericanShorthair,
                     isFavoriteCoreState: false,
                     layoutGuidance: .init(favoriteAlignment: .bottomTrailing, availableWidth: 160.0),
                     onFavoriteTap: { newDesiredState in } )
    }
    Spacer()
}
