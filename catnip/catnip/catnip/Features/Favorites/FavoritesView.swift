//
//  FavoritesView.swift
//  catnip
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import SwiftUI
import ComposableArchitecture
import CatsKitDomain
import CatsKitDomainStaging

struct FavoritesView: View {
    
    @Bindable var store: StoreOf<FavoritesFeature>
    
    @State private var availableWidth: CGFloat = 0.0
    let namespace: Namespace.ID

    var body: some View {
        
        VStack {
            
            switch store.state.browsingModeState {
                
            case .idle:
                idleView
                
            case .bootstrapping:
                bootstrappingView
                
            case let .ready(breeds):
                readyView(breeds: breeds.elements)
            }
        }
        .animation(animation, value: store.browsingModeState)
        .navigationTitle(L10n.favoritesTitle.localized)
        .navigationBarTitleDisplayMode(.large)
        .onAppear { store.send(.onAppear) }
    }
}

extension FavoritesView {
    
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
            Spacer()
        }
    }
    
    @ViewBuilder
    var bootstrappingView: some View {
        
        ProgressView()
            .tint(.accent)
    }
    
    @ViewBuilder
    func readyView(breeds: [CatBreed]) -> some View {
        
        if breeds.isEmpty {

            HStack {
                Spacer()
                Image(systemName: Constants.Empty.systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.accent)
                    .frame(width: Constants.Empty.size)
                    .opacity(Constants.Empty.opacity)
                    .padding()
                Spacer()
            }

        } else {
            
            ScrollView {

                if let averageLifespan {

                    VStack {
                        Text(L10n.favoritesAverageLifespan.localized(averageLifespan))
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.Lifespan.radius))
                    .padding(.horizontal)
                    .padding(.bottom, Constants.Lifespan.radius)
                }

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
                                     .onTapGesture { store.send(.breedTapped(item)) }
                                     .matchedTransitionSource(id: "catbreed-\(item.id)", in: namespace)
                    }
                }
                          .padding(Constants.Grid.horizontalSpacing)
                          .onGeometryChange(for: CGFloat.self) { proxy in
                              proxy.size.width
                          } action: { availableWidth = $0 }
            }
            .accessibilityIdentifier("FavoritesScrollView")
        }
    }
    
    var animation: Animation {
        
        .smooth(duration: Constants.Grid.animation)
    }
    
    var averageLifespan: String? {
        
        guard case let .ready(breeds) = store.state.browsingModeState else {
            return nil
        }
        
        let lifespans = breeds.compactMap { breed -> Float? in
            
            let components = breed.lifeSpan
                .split(separator: "-")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            guard let component = components.last,
                  let componentNumber = Float(component) else {
                return nil
                
            }
            
            return componentNumber
        }
        
        guard lifespans.isEmpty == false else {
            
            return nil
        }
        
        let average = lifespans.reduce(0, +) / Float(lifespans.count)
        
        return String(format: "%.1f", average)
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
            static let animation = 0.2
        }
        
        enum Idle {
            
            static let systemName = "cat"
            static let size = 60.0
            static let opacity = 0.4
        }
        
        enum Empty {
            
            static let systemName = "heart.slash"
            static let size = 60.0
            static let opacity = 0.4
        }
        
        enum Lifespan {
            
            static let radius = 12.0
            static let padding = 8.0
        }
    }
}

#Preview {

    @Previewable @Namespace var namespace

    let core = Core.testValue
        
    if let catGateway = core.managers.catGateway as? CatGateway {
     
        do {
            try catGateway.insert([
                CatBreed.make(from: .mockAbyssinian, favorited: Date()),
                CatBreed.make(from: .mockAegean, favorited: Date().addingTimeInterval(1)),
            ])
        }
        catch {}
    }
    
    return FavoritesView(
        store: Store(initialState: FavoritesFeature.State(),
                     reducer: { FavoritesFeature() }) {
                         $0.core = core
                         $0.catGateway = core.managers.catGateway
                     },
        namespace: namespace
    )
}
