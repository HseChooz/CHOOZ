import Foundation

@MainActor
struct CollectionViewStateBuilder {
    
    // MARK: - Internal Methods
    
    func buildLoadedContentViewState(
        from payload: CollectionPayload,
        selectedTags: Set<String>
    ) -> CollectionLoadedView.Model {
        let filteredItems = filterItems(payload.items, selectedTags: selectedTags)
        
        return CollectionLoadedView.Model(
            header: CollectionHeaderView.Model(
                title: payload.title,
                description: payload.description
            ),
            filters: payload.tags.map { tag in
                let normalizedTag = normalizedTagKey(from: tag)
                
                return CollectionFilterView.Model(
                    id: normalizedTag,
                    tag: tag,
                    title: tag,
                    isSelected: selectedTags.contains(normalizedTag)
                )
            },
            itemCards: filteredItems.map { item in
                CollectionItemCardView.Model(
                    id: item.id,
                    title: item.title,
                    priceText: buildPriceText(price: item.price, currency: item.currency),
                    imageUrl: item.imageUrl,
                    isAdded: item.isAdded
                )
            }
        )
    }
    
    func buildErrorViewState(from error: CollectionErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }
    
    // MARK: - Private Methods
    
    private func filterItems(
        _ items: [CollectionPayload.Item],
        selectedTags: Set<String>
    ) -> [CollectionPayload.Item] {
        guard !selectedTags.isEmpty else {
            return items
        }
        
        return items.filter { item in
            let itemTagKeys = Set(item.tags.map(normalizedTagKey(from:)))
            return !itemTagKeys.isDisjoint(with: selectedTags)
        }
    }
    
    private func buildPriceText(price: String?, currency: WishCurrency?) -> String {
        guard let currency else {
            return price ?? "-"
        }
        
        if let price, !price.isEmpty {
            return "\(price) \(currency.symbol)"
        }
        
        return "- \(currency.symbol)"
    }
    
    private func normalizedTagKey(from tag: String) -> String {
        tag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
    
}
