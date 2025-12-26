//
//  CatBreed.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation

/// Model that represents the cat breed
public struct CatBreed: Identifiable, Equatable, Hashable, Sendable {

    public let id: String
    public let name: String
    public let temperament: String
    public let origin: String
    public let catDescription: String
    public let lifeSpan: String
    public let imageURL: String?
    public let favorited: Date?

    public init(
        id: String,
        name: String,
        temperament: String,
        origin: String,
        catDescription: String,
        lifeSpan: String,
        imageURL: String?,
        favorited: Date?) {

        self.id = id
        self.name = name
        self.temperament = temperament
        self.origin = origin
        self.catDescription = catDescription
        self.lifeSpan = lifeSpan
        self.imageURL = imageURL
        self.favorited = favorited
    }

    public static func make(from otherCatBreed: CatBreed,
                            favorited: Date?) -> CatBreed {

        .init(id: otherCatBreed.id,
              name: otherCatBreed.name,
              temperament: otherCatBreed.temperament,
              origin: otherCatBreed.origin,
              catDescription: otherCatBreed.catDescription,
              lifeSpan: otherCatBreed.lifeSpan,
              imageURL: otherCatBreed.imageURL,
              favorited: favorited)
    }
}
