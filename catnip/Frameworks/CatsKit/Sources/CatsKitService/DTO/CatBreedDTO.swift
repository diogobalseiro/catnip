//
//  CatBreedDTO.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import CatsKitDomain

/// Data transfer object for the cat breed
public struct CatBreedDTO: Equatable, Decodable {

    public let id: String
    public let name: String
    public let temperament: String
    public let origin: String
    public let catDescription: String
    public let lifeSpan: String
    public let imageURL: String?

    public init(
        id: String,
        name: String,
        temperament: String,
        origin: String,
        catDescription: String,
        lifeSpan: String,
        imageURL: String?) {

            self.id = id
            self.name = name
            self.temperament = temperament
            self.origin = origin
            self.catDescription = catDescription
            self.lifeSpan = lifeSpan
            self.imageURL = imageURL
        }

    private enum CodingKeys: String, CodingKey {

        case id, name, temperament, origin, description, image
        case lifeSpan = "life_span"
    }

    private enum ImageCodingKeys: String, CodingKey {
        case url
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        temperament = try container.decode(String.self, forKey: .temperament)
        origin = try container.decode(String.self, forKey: .origin)
        catDescription = try container.decode(String.self, forKey: .description)
        lifeSpan = try container.decode(String.self, forKey: .lifeSpan)

        if container.contains(.image) {

            let imageContainer = try container.nestedContainer(keyedBy: ImageCodingKeys.self, forKey: .image)
            imageURL = try imageContainer.decodeIfPresent(String.self, forKey: .url)

        } else {

            imageURL = nil
        }
    }
}

public extension CatBreedDTO {

    func toDomain() -> CatBreed {

        .init(id: id,
              name: name,
              temperament: temperament,
              origin: origin,
              catDescription: catDescription,
              lifeSpan: lifeSpan,
              imageURL: imageURL,
              favorited: nil)
    }

    static func fromDomain(_ catBreed: CatBreed) -> CatBreedDTO {

        .init(id: catBreed.id,
              name: catBreed.name,
              temperament: catBreed.temperament,
              origin: catBreed.origin,
              catDescription: catBreed.catDescription,
              lifeSpan: catBreed.lifeSpan,
              imageURL: catBreed.imageURL)
    }
}
