import Foundation

enum SocialProfileViewState {
    
    case loading
    case loaded(SocialProfileLoadedModel)
    case error(ScreenErrorView.Model)
    
}

struct SocialProfileLoadedModel {
    let header: ProfileHeaderView.Model
    let itemCards: [SocialProfileItemCard]
    let isEmpty: Bool
}

struct SocialProfileItemCard: Hashable, Identifiable {
    let id: String
    let title: String
    let imageUrl: String?
    let price: String?
    let currency: WishCurrency?
}
