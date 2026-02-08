import SwiftUI
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    
    // MARK: - Init
    
    init(router: ProfileRouter, wishlistViewModel: WishlistViewModel) {
        self.router = router
        self.wishlistViewModel = wishlistViewModel
        headerModel = ProfileHeaderView.Model(userName: "Имя пользователя")
    }
    
    // MARK: - Internal Properties
    
    private(set) var headerModel: ProfileHeaderView.Model
    let wishlistViewModel: WishlistViewModel
    
    var selectedSegment: ProfileSegment = .wishlist
    
    // MARK: - Private Properties
    
    private let router: ProfileRouter
}
