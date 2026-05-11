import SwiftUI
import Observation

@MainActor
protocol MainTabViewModel:
    AnyObject,
    MainTabLoadedViewEventsHandler
{
    var viewState: MainTabViewState { get }
    var searchText: String { get set }
    
    func openProfile()
    func requestSections()
    func retrySectionsRequest()
}

@MainActor
@Observable
final class MainTabViewModelImpl: MainTabViewModel {
    
    // MARK: - Internal Properties
    
    private(set) var viewState: MainTabViewState = .loading
    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            applySearchText()
        }
    }
    
    // MARK: - Init
    
    init(
        router: MainTabRouter,
        interactor: MainTabInteractor,
        viewStateBuilder: MainTabViewStateBuilder,
        analytics: MainTabAnalytics? = nil
    ) {
        self.router = router
        self.interactor = interactor
        self.viewStateBuilder = viewStateBuilder
        self.analytics = analytics
    }
    
    // MARK: - Internal Methods
    
    func requestSections() {
        trackScreenViewedIfNeeded()
        
        guard !hasRequestedSections else {
            return
        }
        
        hasRequestedSections = true
        forceRequestSections()
    }
    
    func openProfile() {
        analytics?.trackProfileOpened()
        router.routeTo(destination: .profile)
    }
    
    // MARK: - MainTabLoadedViewEventsHandler
    
    func refreshSections() {
        viewState = .loading
        forceRequestSections()
    }
    
    func openCollection(with slug: String) {
        analytics?.trackCollectionOpened(collectionSlug: slug)
        router.routeTo(destination: .collection(slug: slug))
    }
        
    func openCollectionsList(with sectionId: String) {
        analytics?.trackCollectionsListOpened(sectionId: sectionId)
        router.routeTo(destination: .collectionsList(id: sectionId))
    }
    
    func openUpcomingEvents() {
        analytics?.trackUpcomingEventsOpened()
        router.routeTo(destination: .calendar)
    }
    
    // MARK: - MainTabErrorViewEventsHandler
    
    func retrySectionsRequest() {
        viewState = .loading
        forceRequestSections()
    }
    
    // MARK: - Private Properties
    
    private let router: MainTabRouter
    private let interactor: MainTabInteractor
    private let viewStateBuilder: MainTabViewStateBuilder
    private let analytics: MainTabAnalytics?
    
    private var hasRequestedSections = false
    private var hasTrackedScreenView = false
    private var payload: MainTabSectionsPayload?
    private var requestSectionsTask: Task<Void, Never>? = nil
    
    // MARK: - Private Methods
    
    private func forceRequestSections() {
        requestSectionsTask?.cancel()
        
        requestSectionsTask = Task {
            do {
                let payload = try await interactor.requestSections()
                self.payload = payload
                viewState = .loaded(viewStateBuilder.buildLoadedContentViewState(
                    from: payload,
                    searchText: searchText
                ))
            } catch let error as MainTabErrorType {
                print(error.localizedDescription)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: error))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: .unknown))
            }
        }
    }
    
    private func applySearchText() {
        guard let payload, case .loaded = viewState else {
            return
        }
        
        viewState = .loaded(viewStateBuilder.buildLoadedContentViewState(
            from: payload,
            searchText: searchText
        ))
    }
    
    private func trackScreenViewedIfNeeded() {
        guard !hasTrackedScreenView else { return }
        
        hasTrackedScreenView = true
        analytics?.trackScreenViewed()
    }

}
