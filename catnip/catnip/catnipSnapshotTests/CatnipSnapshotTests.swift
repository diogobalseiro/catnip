//
//  catnipSnapshotTests.swift
//  catnipSnapshotTests
//
//  Created by Diogo Balseiro on 28/12/2025.
//

import Testing
import SnapshotTesting
@testable import catnip
import CatsKitDomain
import CatsKitDomainStaging
import SwiftUI
import Foundation
import ComposableArchitecture
import XCTest

@Suite("View")
@MainActor
struct CatnipItemViewSnapshotTests {
    
    static let fixedFavoriteDate = Date()

    @Test("ListItemView",
        .serialized,
          arguments: [
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .topLeading,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .topTrailing,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomLeading,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomTrailing,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .topLeading,
                                            availableWidth: 320.0)
            ),
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .topTrailing,
                                            availableWidth: 320.0)
            ),
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomLeading,
                                            availableWidth: 320.0)
            ),
            (
                CatBreed.mockAbyssinian,
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomTrailing,
                                            availableWidth: 320.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .topLeading,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .topTrailing,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomLeading,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomTrailing,
                                            availableWidth: 160.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .topLeading,
                                            availableWidth: 320.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .topTrailing,
                                            availableWidth: 320.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomLeading,
                                            availableWidth: 320.0)
            ),
            (
                CatBreed.make(from: CatBreed.mockAmericanCurl, favorited: fixedFavoriteDate),
                ListItemView.LayoutGuidance(favoriteAlignment: .bottomTrailing,
                                            availableWidth: 320.0)
            ),
          ])
    func listItemView(breed: CatBreed,
                      layoutGuidance: ListItemView.LayoutGuidance) async throws {

        let filename = [
            "ListItemView",
            breed.id,
            breed.favorited != nil ? "favorited" : "notFavorited",
            "w\(Int(layoutGuidance.availableWidth))",
            layoutGuidance.favoriteAlignment.shortName
        ].joined(separator: "-")

        try await LocalImageLoader.load(catbreed: breed)
        try await Task.sleep(for: .milliseconds(100))

        let view = ListItemView(catBreed: breed,
                                isFavoriteCoreState: breed.favorited != nil,
                                layoutGuidance: layoutGuidance) { _ in }
        let snap = VStack {
            view
            Spacer()
        }

        withSnapshotTesting(record: .missing) {
            assertSnapshot(of: snap,
                           as: .image(layout: .device(config: .iPhone13Pro)),
                           testName: filename)
        }
    }

    @Test("DetailView",
          .serialized,
          arguments: [
            (
                CatBreed.mockAmericanBobtail,
                SwiftUISnapshotLayout.device(config: .iPhone13Pro)
            ),
            (
                CatBreed.mockAmericanBobtail,
                SwiftUISnapshotLayout.device(config: .iPhone13Mini)
            ),
            (
                CatBreed.mockAmericanBobtail,
                SwiftUISnapshotLayout.device(config: .iPhone13ProMax)
            ),
            (
                CatBreed.mockAmericanBobtail,
                SwiftUISnapshotLayout.device(config: .iPhoneSe)
            ),
            (
                CatBreed.make(from: CatBreed.mockBambino, favorited: fixedFavoriteDate),
                SwiftUISnapshotLayout.device(config: .iPhone13Pro)
            ),
            (
                CatBreed.make(from: CatBreed.mockBambino, favorited: fixedFavoriteDate),
                SwiftUISnapshotLayout.device(config: .iPhone13Mini)
            ),
            (
                CatBreed.make(from: CatBreed.mockBambino, favorited: fixedFavoriteDate),
                SwiftUISnapshotLayout.device(config: .iPhone13ProMax)
            ),
            (
                CatBreed.make(from: CatBreed.mockBambino, favorited: fixedFavoriteDate),
                SwiftUISnapshotLayout.device(config: .iPhoneSe)
            )
          ])
    func detailView(breed: CatBreed,
                    snapshotLayout: SwiftUISnapshotLayout) async throws {

        let filename = [
            "DetailView",
            breed.id,
            breed.favorited != nil ? "favorited" : "notFavorited",
            snapshotLayout.shortName
        ].joined(separator: "-")

        try await LocalImageLoader.load(catbreed: breed)
        try await Task.sleep(for: .milliseconds(100))

        let store = Store(initialState: DetailFeature.State(catBreed: breed)) {
            DetailFeature()
        }

        let view = DetailView(store: store,
                              isFavoriteCoreState: breed.favorited != nil)

        withSnapshotTesting(record: .never) {
            assertSnapshot(of: view,
                           as: .image(layout: snapshotLayout),
                           testName: filename)
        }
    }
}
