import SwiftUI
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    
    // MARK: - Init
    
    init(
        router: ProfileRouter,
        profileService: ProfileService,
        wishlistViewModel: WishlistViewModel,
        analytics: ProfileAnalytics
    ) {
        self.router = router
        self.profileService = profileService
        self.wishlistViewModel = wishlistViewModel
        self.analytics = analytics
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
        analytics.trackScreenViewed()
        Task {
            await profileService.fetchMe()
            if let userId = profileService.userId {
                analytics.setUserProfileID(userId)
            }
        }
    }
    
    func openSettings() {
        router.routeTo(destination: .settings)
    }
    
    func shareProfile() {
        guard let userId = profileService.userId else { return }
        guard let url = URL(string: "chooz://profile/\(userId)") else { return }
        analytics.trackProfileShared(userId: userId)
        router.presentShareSheet(items: [url])
    }
    
    // MARK: - Private Properties
    
    private let router: ProfileRouter
    private let profileService: ProfileService
    private let analytics: ProfileAnalytics
}
