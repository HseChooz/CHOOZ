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
        analytics: ProfileAnalytics,
        llmService: LLMService,
        analyticsService: AnalyticsService
    ) {
        self.router = router
        self.profileService = profileService
        self.wishlistViewModel = wishlistViewModel
        self.analytics = analytics
        self.llmService = llmService
        self.analyticsService = analyticsService
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
    var isAIInsightsPresented: Bool = false
    
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
    
    func openAIInsights() {
        isAIInsightsPresented = true
    }
    
    func makeAIInsightsViewModel() -> AIInsightsViewModel {
        let userName = [profileService.firstName, profileService.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        let aiAnalytics = AIInsightsAnalytics(analyticsService: analyticsService, source: "profile")
        return AIInsightsViewModel(
            llmService: llmService,
            items: wishlistViewModel.currentWishes,
            userName: userName.isEmpty ? nil : userName,
            analytics: aiAnalytics
        )
    }
    
    // MARK: - Private Properties
    
    private let router: ProfileRouter
    private let profileService: ProfileService
    private let analytics: ProfileAnalytics
    private let llmService: LLMService
    private let analyticsService: AnalyticsService
}
