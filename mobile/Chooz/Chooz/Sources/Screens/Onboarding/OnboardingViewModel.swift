import SwiftUI
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    
    // MARK: - Init
    
    init(
        router: OnboardingRouter,
        userDefaultsService: UserDefaultsService,
        analytics: OnboardingAnalytics
    ) {
        self.router = router
        self.userDefaultsService = userDefaultsService
        self.analytics = analytics
    }
    
    // MARK: - Internal Properties
    
    var currentPage: OnboardingPageType = .start
    
    var currentPageIndex: Int {
        currentPage.rawValue
    }
    
    var indicatorTotalPages: Int {
        OnboardingPageType.allCases.count - 1
    }
    
    var indicatorCurrentIndex: Int {
        max(0, currentPageIndex - 1)
    }
    
    var showsIndicator: Bool {
        currentPage != .start
    }
    
    var showsSkipButton: Bool {
        currentPage != .finish
    }
    
    var primaryButtonTitle: String {
        switch currentPage {
        case .start:
            return "Ознакомиться с функциями"
        case .collections, .wishlist, .calendar, .notes:
            return "Дальше"
        case .finish:
            return "Перейти к регистрации"
        }
    }
    
    // MARK: - Internal Methods
    
    func nextPage() {
        guard let nextIndex = OnboardingPageType(rawValue: currentPage.rawValue + 1) else {
            finishOnboarding(skipped: false)
            return
        }
        
        currentPage = nextIndex
    }
        
    func skip() {
        finishOnboarding(skipped: true)
    }
    
    // MARK: - Private Properties
    
    private let router: OnboardingRouter
    private let userDefaultsService: UserDefaultsService
    private let analytics: OnboardingAnalytics
    
    // MARK: - Private Methods
        
    private func finishOnboarding(skipped: Bool) {
        userDefaultsService.hasSeenOnboarding = true
        analytics.trackOnboardingCompleted(skipped: skipped)
        router.routeToAuthorizationScreen()
    }
}
