import Foundation

@MainActor
struct CollectionsListViewStateBuilder {
    
    func buildLoadedContentViewState(from payload: CollectionsListPayload) -> CollectionsListLoadedView.Model {
        CollectionsListLoadedView.Model(
            title: payload.title,
            collections: payload.collections.map { collection in
                CollectionsListCollectionCardView.Model(
                    slug: collection.slug,
                    title: collection.title,
                    subtitle: makeItemsCountSubtitle(for: collection.itemsCount),
                    imageUrl: collection.coverImageUrl
                )
            }
        )
    }
    
    func buildErrorViewState(from error: CollectionsListErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }
    
    // MARK: - Private Methods
    
    private func makeItemsCountSubtitle(for itemsCount: Int) -> String {
        let remainder100 = itemsCount % 100
        let remainder10 = itemsCount % 10
        
        let noun: String
        
        if remainder100 >= 11 && remainder100 <= 14 {
            noun = "товаров"
        } else {
            switch remainder10 {
            case 1:
                noun = "товар"
            case 2...4:
                noun = "товара"
            default:
                noun = "товаров"
            }
        }
        
        return "\(itemsCount) \(noun)"
    }
    
}
