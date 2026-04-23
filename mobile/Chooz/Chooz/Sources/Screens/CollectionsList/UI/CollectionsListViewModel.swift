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
        viewStateBuilder: CollectionsListViewStateBuilder
    ) {
        self.interactor = interactor
        self.router = router
        self.viewStateBuilder = viewStateBuilder
    }
    
    // MARK: - Internal Methods
    
    func requestCollectionsList() {
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
    
    func openCollection(with collectionId: String) {
        router.routeTo(destination: .collection(id: collectionId))
    }
    
    // MARK: - Private Properties
    
    private let interactor: CollectionsListInteractor
    private let router: CollectionsListRouter
    private let viewStateBuilder: CollectionsListViewStateBuilder
    
    private var hasRequestedCollectionsList = false
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
    
}
