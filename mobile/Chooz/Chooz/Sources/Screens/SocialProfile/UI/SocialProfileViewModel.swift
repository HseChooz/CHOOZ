import SwiftUI
import Observation

@MainActor
protocol SocialProfileViewModel:
    AnyObject,
    SocialProfileLoadedViewEventsHandler
{
    var viewState: SocialProfileViewState { get }
    var isInsightSheetPresented: Bool { get set }
    var insightService: WishlistInsightService { get }
    var insightItems: [WishlistItem] { get }

    func requestProfile()
    func retryProfileRequest()
}

@MainActor
@Observable
final class SocialProfileViewModelImpl: SocialProfileViewModel {
    
    // MARK: - Internal Properties

    private(set) var viewState: SocialProfileViewState = .loading
    var isInsightSheetPresented: Bool = false
    let insightService: WishlistInsightService

    var insightItems: [WishlistItem] {
        sourcePayload?.items ?? []
    }

    // MARK: - Init

    init(
        interactor: SocialProfileInteractor,
        router: any SocialProfileRouter,
        viewStateBuilder: SocialProfileViewStateBuilder,
        insightService: WishlistInsightService,
        analytics: SocialProfileAnalytics
    ) {
        self.interactor = interactor
        self.router = router
        self.viewStateBuilder = viewStateBuilder
        self.insightService = insightService
        self.analytics = analytics
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

    func openAIInsight() {
        insightService.reset()
        isInsightSheetPresented = true
    }
    
    // MARK: - Private Properties
    
    private let interactor: SocialProfileInteractor
    private let router: any SocialProfileRouter
    private let viewStateBuilder: SocialProfileViewStateBuilder
    private let analytics: SocialProfileAnalytics
    
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
