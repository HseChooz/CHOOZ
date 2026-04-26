import SwiftUI

@MainActor
protocol CollectionsListViewModel:
    AnyObject,
    CollectionsListLoadedViewEventsHandler
{
    var viewState: CollectionsListViewState { get }
    
    func requestCollectionsList()
    func retryCollectionsListRequest()
}

@MainActor
@Observable
final class CollectionsListViewModelImpl: CollectionsListViewModel {
    
    // MARK: - Internal Properties
    
    private(set) var viewState: CollectionsListViewState = .loading
    
    // MARK: - Init
    
    init(
        interactor: CollectionsListInteractor,
        router: CollectionsListRouter,
        viewStateBuilder: CollectionsListViewStateBuilder,
        analytics: CollectionsListAnalytics? = nil
    ) {
        self.interactor = interactor
        self.router = router
        self.viewStateBuilder = viewStateBuilder
        self.analytics = analytics
    }
    
    // MARK: - Internal Methods
    
    func requestCollectionsList() {
        trackScreenViewedIfNeeded()
        
        guard !hasRequestedCollectionsList else {
            return
        }
        
        hasRequestedCollectionsList = true
        forceRequestCollectionsList()
    }
    
    func retryCollectionsListRequest() {
        viewState = .loading
        forceRequestCollectionsList()
    }
    
    func refreshCollectionsList() {
        viewState = .loading
        forceRequestCollectionsList()
    }
    
    func openCollection(with collectionSlug: String) {
        analytics?.trackCollectionOpened(collectionSlug: collectionSlug)
        router.routeTo(destination: .collection(slug: collectionSlug))
    }
    
    // MARK: - Private Properties
    
    private let interactor: CollectionsListInteractor
    private let router: CollectionsListRouter
    private let viewStateBuilder: CollectionsListViewStateBuilder
    private let analytics: CollectionsListAnalytics?
    
    private var hasRequestedCollectionsList = false
    private var hasTrackedScreenView = false
    private var requestCollectionsListTask: Task<Void, Never>? = nil
    
    // MARK: - Private Methods
    
    private func forceRequestCollectionsList() {
        requestCollectionsListTask?.cancel()
        
        requestCollectionsListTask = Task {
            do {
                let payload = try await interactor.requestCollectionsList()
                viewState = .loaded(viewStateBuilder.buildLoadedContentViewState(from: payload))
            } catch let error as CollectionsListErrorType {
                print(error.localizedDescription)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: error))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: .unknown))
            }
        }
    }
    
    private func trackScreenViewedIfNeeded() {
        guard !hasTrackedScreenView else { return }
        
        hasTrackedScreenView = true
        analytics?.trackScreenViewed()
    }
    
}
