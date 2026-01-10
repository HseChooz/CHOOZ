import SwiftUI
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    
    // MARK: - Init
    
    init(router: OnboardingRouter, userDefaultsService: UserDefaultsService) {
        self.router = router
        self.userDefaultsService = userDefaultsService
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
            return "Поехали!"
        case .wishlist, .calendar:
            return "Дальше"
        case .finish:
            return "На главный экран"
        }
    }
    
    // MARK: - Internal Methods
    
    func onAppear() {
        userDefaultsService.hasSeenOnboarding = true
    }
    
    func nextPage() {
        guard let nextIndex = OnboardingPageType(rawValue: currentPage.rawValue + 1) else {
            finishOnboarding()
            return
        }
        
        currentPage = nextIndex
    }
        
    func skip() {
        finishOnboarding()
    }
    
    // MARK: - Private Properties
    
    private let router: OnboardingRouter
    private let userDefaultsService: UserDefaultsService
    
    // MARK: - Private Methods
        
    private func finishOnboarding() {
        router.routeToAuthorizationScreen()
    }
}
