import SwiftUI
import Observation

@MainActor
protocol CollectionItemDetailsViewModel:
    AnyObject,
    CollectionItemDetailsLoadedViewEventsHandler
{
    var viewState: CollectionItemDetailsViewState { get }
    
    func requestCollectionItemDetails()
    func retryCollectionItemDetailsRequest()
}

@MainActor
@Observable
final class CollectionItemDetailsViewModelImpl: CollectionItemDetailsViewModel {
    
    // MARK: - Internal Properties

    private(set) var viewState: CollectionItemDetailsViewState = .loading
    
    // MARK: - Init
    
    init(
        interactor: CollectionItemDetailsInteractor,
        viewStateBuilder: CollectionItemDetailsViewStateBuilder,
        wishlistPerformer: any CollectionWishlistActionPerformer,
        wishlistReporter: any CollectionWishlistActionReporter
    ) {
        self.interactor = interactor
        self.viewStateBuilder = viewStateBuilder
        self.wishlistPerformer = wishlistPerformer
        self.wishlistReporter = wishlistReporter
        
        let observer = WishlistObserver()
        self.wishlistObserver = observer
        
        observer.onWillPerform = { [weak self] action, itemId in
            self?.handleWillPerform(action: action, itemId: itemId)
        }
        observer.onFailPerform = { [weak self] action, itemId in
            self?.handleFailPerform(action: action, itemId: itemId)
        }
        
        wishlistReporter.addObserver(observer)
    }
    
    // MARK: - Internal Methods
    
    func requestCollectionItemDetails() {
        guard !hasRequestedCollectionItemDetails else {
            return
        }
        
        hasRequestedCollectionItemDetails = true
        forceRequestCollectionItemDetails()
    }
    
    func retryCollectionItemDetailsRequest() {
        viewState = .loading
        forceRequestCollectionItemDetails()
    }
    
    func addToWishlist(collectionItemId: String) {
        performWishlistAction(.add, collectionItemId: collectionItemId)
    }
    
    func removeFromWishlist(collectionItemId: String) {
        performWishlistAction(.remove, collectionItemId: collectionItemId)
    }
    
    // MARK: - Private Properties
    
    private let interactor: CollectionItemDetailsInteractor
    private let viewStateBuilder: CollectionItemDetailsViewStateBuilder
    private let wishlistPerformer: any CollectionWishlistActionPerformer
    private let wishlistReporter: any CollectionWishlistActionReporter
    private let wishlistObserver: WishlistObserver
    
    private var hasRequestedCollectionItemDetails = false
    private var requestCollectionItemDetailsTask: Task<Void, Never>? = nil
    private var wishlistTask: Task<Void, Never>? = nil
    private var sourcePayload: CollectionItemDetailsPayload?
    
    // MARK: - Private Methods
    
    private func forceRequestCollectionItemDetails() {
        requestCollectionItemDetailsTask?.cancel()
        
        requestCollectionItemDetailsTask = Task {
            do {
                let payload = try await interactor.requestCollectionItemDetails()
                sourcePayload = payload
                viewState = .loaded(viewStateBuilder.buildLoadedContentViewState(from: payload))
            } catch let error as CollectionItemDetailsErrorType {
                print(error.localizedDescription)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: error))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: .unknown))
            }
        }
    }
    
    private func performWishlistAction(
        _ action: CollectionWishlistAction,
        collectionItemId: String
    ) {
        wishlistTask?.cancel()
        
        wishlistTask = Task(priority: .userInitiated) {
            try? await wishlistPerformer.perform(action: action, for: collectionItemId)
        }
    }
    
    private func handleWillPerform(action: CollectionWishlistAction, itemId: String) {
        updateItemIsAdded(collectionItemId: itemId, isAdded: action == .add)
    }
    
    private func handleFailPerform(action: CollectionWishlistAction, itemId: String) {
        updateItemIsAdded(collectionItemId: itemId, isAdded: action != .add)
    }
    
    private func updateItemIsAdded(collectionItemId: String, isAdded: Bool) {
        guard var payload = sourcePayload,
              payload.id == collectionItemId
        else {
            return
        }
        
        payload.isAdded = isAdded
        sourcePayload = payload
        viewState = .loaded(viewStateBuilder.buildLoadedContentViewState(from: payload))
    }
    
}

// MARK: - WishlistObserver

extension CollectionItemDetailsViewModelImpl {
    
    fileprivate final class WishlistObserver: ActionPerformerObserver, @unchecked Sendable {
        
        // MARK: - Internal Properties
        
        var onWillPerform: (@MainActor (CollectionWishlistAction, String) -> Void)?
        var onFailPerform: (@MainActor (CollectionWishlistAction, String) -> Void)?
        
        // MARK: - ActionPerformerObserver
        
        func willPerform(
            action: CollectionWishlistAction,
            for target: String,
            in performer: any ActionPerformer<CollectionWishlistAction, String, Void>
        ) {
            Task { @MainActor [onWillPerform] in
                onWillPerform?(action, target)
            }
        }
        
        func didPerform(
            action: CollectionWishlistAction,
            for target: String,
            with result: Void,
            in performer: any ActionPerformer<CollectionWishlistAction, String, Void>
        ) {}
        
        func failPerform(
            action: CollectionWishlistAction,
            for target: String,
            with error: Error,
            in performer: any ActionPerformer<CollectionWishlistAction, String, Void>
        ) {
            Task { @MainActor [onFailPerform] in
                onFailPerform?(action, target)
            }
        }
        
    }
    
}
