import Foundation

@MainActor
struct CollectionsListViewStateBuilder {
    
    func buildLoadedContentViewState(from payload: CollectionsListPayload) -> CollectionsListLoadedView.Model {
        CollectionsListLoadedView.Model(
            title: payload.title,
            collections: payload.collections.map { collection in
                CollectionsListCollectionCardView.Model(
                    id: collection.id,
                    title: collection.title,
                    subtitle: collection.subtitle,
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
    
}
