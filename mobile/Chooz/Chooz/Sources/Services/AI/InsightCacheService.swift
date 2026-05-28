import Foundation
import CryptoKit

final class InsightCacheService {

    // MARK: - Internal Methods

    func cachedInsight(for items: [WishlistItem]) -> String? {
        let key = cacheKey(for: items)
        return storage.string(forKey: key)
    }

    func saveInsight(_ insight: String, for items: [WishlistItem]) {
        let key = cacheKey(for: items)
        storage.set(insight, forKey: key)
    }

    func invalidate(for items: [WishlistItem]) {
        let key = cacheKey(for: items)
        storage.removeObject(forKey: key)
    }

    // MARK: - Private Properties

    private let storage = UserDefaults.standard
    private let keyPrefix = "ai_insight_"

    // MARK: - Private Methods

    private func cacheKey(for items: [WishlistItem]) -> String {
        let ids = items.map(\.id).sorted().joined(separator: ",")
        let hash = SHA256.hash(data: Data(ids.utf8))
        let hashString = hash.prefix(16).map { String(format: "%02x", $0) }.joined()
        return keyPrefix + hashString
    }
}
