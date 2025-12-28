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

            (availableWidth * 0.98).rounded(.down)
        }

        var imageHeight: CGFloat {

            (availableWidth * 1.2).rounded(.down)
        }

        var width: CGFloat {

            availableWidth
        }

        var height: CGFloat {

            (availableWidth * 1.5).rounded(.down)
        }
    }

    let catBreed: CatBreed
    let isFavoriteCoreState: Bool
    let layoutGuidance: LayoutGuidance
    let onFavoriteTap: (Bool) -> Void

    @State private var isFavoriteUIState: Bool = false

    var body: some View {

        VStack(alignment: .center, spacing: 8) {

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
            Image(systemName: isFavoriteUIState ? "star.fill" : "star")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundStyle(isFavoriteUIState ? .accent : .white)
                .padding(6)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .fill(isFavoriteUIState ? .accent.opacity(0.2) : .clear)
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
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
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
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
        }

        enum Name {

            static let lineLimit = 1
            static let padding = 5.0
        }

        enum WholeView {

            static let height = 300.0
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
