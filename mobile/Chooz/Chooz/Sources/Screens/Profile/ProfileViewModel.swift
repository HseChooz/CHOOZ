import SwiftUI
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    
    // MARK: - Init
    
    init(
        router: ProfileRouter,
        profileService: ProfileService,
        wishlistViewModel: WishlistViewModel
    ) {
        self.router = router
        self.profileService = profileService
        self.wishlistViewModel = wishlistViewModel
    }
    
    // MARK: - Internal Properties
    
    var headerModel: ProfileHeaderView.Model {
        ProfileHeaderView.Model(
            firstName: profileService.firstName,
            lastName: profileService.lastName,
            isLoading: profileService.isLoading
        )
    }
    
    let wishlistViewModel: WishlistViewModel
    
    var selectedSegment: ProfileSegment = .wishlist
    
    // MARK: - Internal Methods
    
    func fetchProfile() {
        Task {
            await profileService.fetchMe()
        }
    }
    
    func openSettings() {
        router.routeTo(destination: .settings)
    }
    
    // MARK: - Private Properties
    
    private let router: ProfileRouter
    private let profileService: ProfileService
}
