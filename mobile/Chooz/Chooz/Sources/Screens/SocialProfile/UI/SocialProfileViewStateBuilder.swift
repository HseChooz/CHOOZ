import Foundation

@MainActor
struct SocialProfileViewStateBuilder {
    
    // MARK: - Internal Methods
    
    func buildLoadedViewState(from payload: SocialProfilePayload) -> SocialProfileLoadedModel {
        SocialProfileLoadedModel(
            header: ProfileHeaderView.Model(
                firstName: payload.user.firstName,
                lastName: payload.user.lastName,
                isLoading: false
            ),
            itemCards: payload.items.map { item in
                SocialProfileItemCard(
                    id: item.id,
                    title: item.title,
                    imageUrl: item.imageUrl,
                    price: item.price,
                    currency: item.currency
                )
            },
            isEmpty: payload.items.isEmpty
        )
    }
    
    func buildErrorViewState(from error: SocialProfileErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }
    
}
