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
        insightService: WishlistInsightService,
        analytics: ProfileAnalytics
    ) {
        self.router = router
        self.profileService = profileService
        self.wishlistViewModel = wishlistViewModel
        self.insightService = insightService
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
    let insightService: WishlistInsightService

    var selectedSegment: ProfileSegment = .wishlist
    var isInsightSheetPresented: Bool = false

    var isInsightAvailable: Bool {
        if case .loaded = wishlistViewModel.wishlistState { return true }
        return false
    }

    var wishlistItems: [WishlistItem] {
        if case .loaded(let items) = wishlistViewModel.wishlistState { return items }
        return []
    }

    private var isDataLoaded: Bool = false
    
    // MARK: - Internal Methods
    
    func fetchProfile(force: Bool = false) {
        guard force || !isDataLoaded else { return }
        
        analytics.trackScreenViewed()
        Task {
            await profileService.fetchMe()
            if let userId = profileService.userId {
                analytics.setUserProfileID(userId)
            }
            isDataLoaded = true
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

    func openAIInsight() {
        insightService.reset()
        isInsightSheetPresented = true
    }

    // MARK: - Private Properties

    private let router: ProfileRouter
    private let profileService: ProfileService
    private let analytics: ProfileAnalytics
}
