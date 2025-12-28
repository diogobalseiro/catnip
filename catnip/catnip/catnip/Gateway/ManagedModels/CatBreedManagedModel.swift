//
//  CatBreedManagedModel.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Foundation
import SwiftData
import CatsKitDomain

@Model
final class CatBreedManagedModel {

    @Attribute(.unique)
    var id: String
    var name: String
    var temperament: String
    var origin: String
    var catDescription: String
    var lifeSpan: String
    var imageURL: String?
    var favorited: Date?
    var createdAt: Date?

    init(id: String,
         name: String,
         temperament: String,
         origin: String,
         catDescription: String,
         lifeSpan: String,
         imageURL: String? = nil,
         favorited: Date?,
         createdAt: Date?) {

        self.id = id
        self.name = name
        self.temperament = temperament
        self.origin = origin
        self.catDescription = catDescription
        self.lifeSpan = lifeSpan
        self.imageURL = imageURL
        self.favorited = favorited
        self.createdAt = createdAt
    }
}

extension CatBreedManagedModel {

    func toDomain() -> CatBreed {

        .init(id: id,
              name: name,
              temperament: temperament,
              origin: origin,
              catDescription: catDescription,
              lifeSpan: lifeSpan,
              imageURL: imageURL,
              favorited: favorited)
    }

    static func makeReadyForInsertion(_ domain: CatBreed) -> CatBreedManagedModel {

        .init(id: domain.id,
              name: domain.name,
              temperament: domain.temperament,
              origin: domain.origin,
              catDescription: domain.catDescription,
              lifeSpan: domain.lifeSpan,
              imageURL: domain.imageURL,
              favorited: domain.favorited,
              createdAt: Date())
    }
}
