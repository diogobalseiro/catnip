//
//  LocalImageLoader.swift
//  catnipSnapshotTests
//
//  Created by Diogo Balseiro on 28/12/2025.
//

import Foundation
import CatsKitDomain
import UIKit
@testable import catnip

@objc final class LocalImageLoader: NSObject {

    private static let testBundle: Bundle = { Bundle(for: LocalImageLoader.self) }()

    enum TestError: Error {

        case noResourceURL
        case noData
        case noBreedURL
        case noImage
    }

    static func load(catbreed: CatBreed) async throws {

        guard let url = testBundle.url(forResource: catbreed.id,
                                       withExtension: "jpg") else { throw TestError.noResourceURL }
        guard let data = try? Data(contentsOf: url) else { throw TestError.noData }
        guard let imageURL = URL(possibleString: catbreed.imageURL) else { throw TestError.noBreedURL }
        guard let image = UIImage(data: data) else { throw TestError.noImage }

        await ImageCache.shared.storeImage(image, url: imageURL)
    }
}
