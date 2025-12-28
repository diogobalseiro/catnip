//
//  CachedImage.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Foundation
import SwiftUI

struct CachedImage: View {

    private struct LocalState {

        let image: UIImage
        let url: URL
    }

    @State private var localState: LocalState?

    let desiredURL: URL?
    let animation: Animation

    init(desiredURL: URL? = nil,
         animation: Animation = .default) {

        self.desiredURL = desiredURL
        self.animation = animation
    }

    var body: some View {

        VStack {

            if let image {

                Image(uiImage: image)
                    .resizable()

            } else {

                Color(.systemGray6)
            }
        }
        .animation(animation, value: image)
        .task(id: desiredURL) {

            if Task.isCancelled { return }

            if localState != nil,
               localState?.url.absoluteString != desiredURL?.absoluteString {

                localState = nil
            }

            guard image == nil,
                    let urlToFetch = desiredURL else { return }

            let fetchedImage = await ImageCache.shared.fetchedImage(url: urlToFetch)

            if Task.isCancelled { return }

            if let fetchedImage,
               let desiredURL = desiredURL,
               desiredURL == urlToFetch {

                localState = .init(image: fetchedImage, url: desiredURL)
            }
        }
    }

    var image: UIImage? {

        localState?.image ?? ImageCache.shared.cachedImage(url: desiredURL)
    }
}

