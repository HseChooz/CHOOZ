import Foundation
import SwiftUI
import Kingfisher

struct CachedAsyncImage<Placeholder: View>: View {
    
    // MARK: - Init
    
    init(url: URL?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder
    }
    
    // MARK: - Body
    
    var body: some View {
        if let url = url {
            let cacheKey = Self.stableCacheKey(for: url)
            KFImage.url(url, cacheKey: cacheKey)
                .cacheOriginalImage()
                .diskCacheExpiration(.days(AppConfig.ImageCache.cacheExpirationDays))
                .memoryCacheExpiration(.days(AppConfig.ImageCache.cacheExpirationDays))
                .placeholder {
                    placeholder()
                }
                .loadTransition(.scale, animation: .easeInOut(duration: 0.25))
                .resizable()
        } else {
            placeholder()
        }
    }
    
    // MARK: - Private Properties
    
    private let url: URL?
    @ViewBuilder private let placeholder: () -> Placeholder
    
    // MARK: - Private Methods
    
    /// Presigned URLs change query parameters; Kingfisher defaults to full `absoluteString` as cache key.
    private static func stableCacheKey(for url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString
        }
        components.query = nil
        components.fragment = nil
        return components.url?.absoluteString ?? url.absoluteString
    }
}
