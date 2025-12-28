//
//  ImageCache.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//


import Foundation
import UIKit
import os

protocol ImageCaching {

    func cachedImage(url: URL?) -> UIImage?

    func fetchedImage(url: URL) async -> UIImage?

    func storeImage(_ image: UIImage, url: URL)
}

class ImageCache: NSObject {

    static var shared = ImageCache()

    private var cache: NSCache<NSString, UIImage>
    private var cacheCount = 0

    init(cache: NSCache<NSString, UIImage> = NSCache()) {

        self.cache = cache
        super.init()
        self.cache.delegate = self
    }
}

extension ImageCache: ImageCaching {

    func cachedImage(url: URL?) -> UIImage? {

        guard let url else { return nil }

        let cacheKey = NSString(string: url.absoluteString)

        if let cachedImage = cache.object(forKey: cacheKey) {

            return cachedImage
        }

        return nil
    }

    func fetchedImage(url: URL) async -> UIImage? {

        if let cachedImage = cachedImage(url: url) {

            return cachedImage
        }

        do {

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                Logger.shared.debug("🎨 Could not download image")
                throw URLError(.badServerResponse)
            }

            guard let image = UIImage(data: data) else {
                Logger.shared.debug("🎨 Could not decode image data")
                throw URLError(.cannotDecodeContentData)
            }

            self.saveImage(image, url: url)
            Logger.shared.debug("🎨 Downloaded and saved image \(url.absoluteString), returning it")

            return image
        }

        catch {

            return nil
        }
    }

    func storeImage(_ image: UIImage, url: URL) {

        self.saveImage(image, url: url)
    }
}

private extension ImageCache {

    func saveImage(_ image: UIImage, url: URL) {

        let cacheKey = NSString(string: url.absoluteString)

        cache.setObject(image, forKey: cacheKey)
        cacheCount += 1
    }
}

extension ImageCache: NSCacheDelegate {

    func cache(_ cache: NSCache<AnyObject, AnyObject>,
               willEvictObject obj: Any) {

        Logger.shared.debug("🎨 Will evict an object from the cache, current count \(self.cacheCount)")
        cacheCount -= 1
    }
}
