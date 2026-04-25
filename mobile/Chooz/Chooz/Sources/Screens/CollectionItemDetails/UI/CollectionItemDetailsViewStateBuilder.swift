import Foundation

@MainActor
struct CollectionItemDetailsViewStateBuilder {
    
    // MARK: - Internal Methods
    
    func buildLoadedContentViewState(from payload: CollectionItemDetailsPayload) -> CollectionItemDetailsLoadedView.Model {
        CollectionItemDetailsLoadedView.Model(
            collectionItemId: payload.id,
            imageUrl: payload.imageUrl,
            wishUrl: payload.link,
            title: payload.title,
            priceText: buildPriceText(price: payload.price, currency: payload.currency),
            description: payload.description,
            isAdded: payload.isAdded
        )
    }
    
    func buildErrorViewState(from error: CollectionItemDetailsErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }
    
    // MARK: - Private Methods
    
    private func buildPriceText(price: String?, currency: WishCurrency?) -> String {
        guard let currency else {
            if let price, !price.isEmpty {
                return price
            }
            
            return "-"
        }
        
        if let price, !price.isEmpty {
            return "\(price) \(currency.symbol)"
        }
        
        return "- \(currency.symbol)"
    }
    
}
