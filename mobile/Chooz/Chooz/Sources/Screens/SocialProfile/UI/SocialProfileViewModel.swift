import SwiftUI
import Observation

@MainActor
protocol SocialProfileViewModel:
    AnyObject,
    SocialProfileLoadedViewEventsHandler
{
    var viewState: SocialProfileViewState { get }
    var isAIInsightsPresented: Bool { get set }
    
    func requestProfile()
    func retryProfileRequest()
    func makeAIInsightsViewModel() -> AIInsightsViewModel
}

@MainActor
@Observable
final class SocialProfileViewModelImpl: SocialProfileViewModel {
    
    // MARK: - Internal Properties
    
    private(set) var viewState: SocialProfileViewState = .loading
    var isAIInsightsPresented: Bool = false
    
    // MARK: - Init
    
    init(
        interactor: SocialProfileInteractor,
        router: any SocialProfileRouter,
        viewStateBuilder: SocialProfileViewStateBuilder,
        analytics: SocialProfileAnalytics,
        llmService: LLMService,
        analyticsService: AnalyticsService
    ) {
        self.interactor = interactor
        self.router = router
        self.viewStateBuilder = viewStateBuilder
        self.analytics = analytics
        self.llmService = llmService
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func requestProfile() {
        trackScreenViewedIfNeeded()
        
        guard !hasRequestedProfile else {
            return
        }
        
        hasRequestedProfile = true
        forceRequestProfile()
    }
    
    func retryProfileRequest() {
        viewState = .loading
        forceRequestProfile()
    }
    
    func refreshProfile() {
        viewState = .loading
        forceRequestProfile()
    }
    
    func openWishlistItem(id: String) {
        guard let item = sourcePayload?.items.first(where: { $0.id == id }) else {
            return
        }
        
        router.routeTo(destination: .wishlistItem(item))
    }
    
    func makeAIInsightsViewModel() -> AIInsightsViewModel {
        let payload = sourcePayload
        let userName = [payload?.user.firstName, payload?.user.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        let aiAnalytics = AIInsightsAnalytics(analyticsService: analyticsService, source: "social_profile")
        return AIInsightsViewModel(
            llmService: llmService,
            items: payload?.items ?? [],
            userName: userName.isEmpty ? nil : userName,
            analytics: aiAnalytics
        )
    }
    
    // MARK: - Private Properties
    
    private let interactor: SocialProfileInteractor
    private let router: any SocialProfileRouter
    private let viewStateBuilder: SocialProfileViewStateBuilder
    private let analytics: SocialProfileAnalytics
    private let llmService: LLMService
    private let analyticsService: AnalyticsService
    
    private var hasRequestedProfile = false
    private var hasTrackedScreenView = false
    private var requestProfileTask: Task<Void, Never>?
    private var sourcePayload: SocialProfilePayload?
    
    // MARK: - Private Methods
    
    private func forceRequestProfile() {
        requestProfileTask?.cancel()
        
        requestProfileTask = Task {
            do {
                let payload = try await interactor.requestProfile()
                sourcePayload = payload
                viewState = .loaded(viewStateBuilder.buildLoadedViewState(from: payload))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: .unknown))
            }
        }
    }
    
    private func trackScreenViewedIfNeeded() {
        guard !hasTrackedScreenView else { return }
        
        hasTrackedScreenView = true
        analytics.trackScreenViewed()
    }
    
}
