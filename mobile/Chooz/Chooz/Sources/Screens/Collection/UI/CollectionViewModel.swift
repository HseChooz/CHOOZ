import SwiftUI
import Observation

@MainActor
protocol CollectionViewModel:
    AnyObject,
    CollectionLoadedViewEventsHandler
{
    var viewState: CollectionViewState { get }

    func requestCollection()
    func retryCollectionRequest()
}

@MainActor
@Observable
final class CollectionViewModelImpl: CollectionViewModel {
    
    // MARK: - Internal Properties

    private(set) var viewState: CollectionViewState = .loading

    // MARK: - Init

    init(
        interactor: CollectionInteractor,
        router: any CollectionRouter,
        viewStateBuilder: CollectionViewStateBuilder,
        wishlistPerformer: any CollectionWishlistActionPerformer,
        wishlistReporter: any CollectionWishlistActionReporter,
        analytics: CollectionAnalytics? = nil,
        collectionSlug: String? = nil
    ) {
        self.interactor = interactor
        self.router = router
        self.viewStateBuilder = viewStateBuilder
        self.wishlistPerformer = wishlistPerformer
        self.wishlistReporter = wishlistReporter
        self.analytics = analytics
        self.collectionSlug = collectionSlug

        let observer = WishlistObserver()
        self.wishlistObserver = observer

        observer.onWillPerform = { [weak self] action, itemId in
            self?.handleWillPerform(action: action, itemId: itemId)
        }
        observer.onDidPerform = { [weak self] action, itemId in
            self?.handleDidPerform(action: action, itemId: itemId)
        }
        observer.onFailPerform = { [weak self] action, itemId in
            self?.handleFailPerform(action: action, itemId: itemId)
        }

        wishlistReporter.addObserver(observer)
    }

    // MARK: - Internal Methods

    func requestCollection() {
        trackScreenViewedIfNeeded()
        
        guard !hasRequestedCollection else {
            return
        }

        hasRequestedCollection = true
        forceRequestCollection()
    }

    func retryCollectionRequest() {
        viewState = .loading
        forceRequestCollection()
    }

    func refreshCollection() {
        viewState = .loading
        forceRequestCollection()
    }

    func toggleFilter(tag: String) {
        guard let sourcePayload else {
            return
        }

        let normalizedTag = Self.normalizedTagKey(from: tag)
        let isEnabled: Bool

        if selectedTags.contains(normalizedTag) {
            selectedTags.remove(normalizedTag)
            isEnabled = false
        } else {
            selectedTags.insert(normalizedTag)
            isEnabled = true
        }

        viewState = .loaded(
            viewStateBuilder.buildLoadedContentViewState(
                from: sourcePayload,
                selectedTags: selectedTags
            )
        )
        
        analytics?.trackFilterToggled(
            collectionSlug: sourcePayload.slug,
            tag: tag,
            enabled: isEnabled
        )
    }

    func toggleWishlistItem(id: String, isAdded: Bool) {
        let action: CollectionWishlistAction = isAdded ? .remove : .add
        pendingAnalyticsWishlistActions[id] = action

        wishlistTask?.cancel()
        wishlistTask = Task(priority: .userInitiated) {
            do {
                try await wishlistPerformer.perform(action: action, for: id)
            } catch {
                if Task.isCancelled {
                    pendingAnalyticsWishlistActions[id] = nil
                }
            }
        }
    }
    
    func openCollectionItemDetails(itemId: String) {
        guard let collectionSlug = sourcePayload?.slug else {
            return
        }
        
        analytics?.trackItemOpened(collectionSlug: collectionSlug, itemId: itemId)
        router.routeTo(destination: .collectionItemDetails(
            collectionSlug: collectionSlug,
            itemId: itemId,
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        ))
    }

    // MARK: - Private Properties

    private let interactor: CollectionInteractor
    private let router: any CollectionRouter
    private let viewStateBuilder: CollectionViewStateBuilder
    private let wishlistPerformer: any CollectionWishlistActionPerformer
    private let wishlistReporter: any CollectionWishlistActionReporter
    private let wishlistObserver: WishlistObserver
    private let analytics: CollectionAnalytics?
    private let collectionSlug: String?

    private var hasRequestedCollection = false
    private var hasTrackedScreenView = false
    private var requestCollectionTask: Task<Void, Never>?
    private var wishlistTask: Task<Void, Never>?
    private var sourcePayload: CollectionPayload?
    private var selectedTags: Set<String> = []
    private var pendingAnalyticsWishlistActions: [String: CollectionWishlistAction] = [:]

    // MARK: - Private Methods

    private func forceRequestCollection() {
        requestCollectionTask?.cancel()

        requestCollectionTask = Task {
            do {
                let payload = try await interactor.requestCollection()
                sourcePayload = payload
                viewState = .loaded(
                    viewStateBuilder.buildLoadedContentViewState(
                        from: payload,
                        selectedTags: selectedTags
                    )
                )
            } catch let error as CollectionErrorType {
                print(error.localizedDescription)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: error))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: .unknown))
            }
        }
    }

    private func handleWillPerform(action: CollectionWishlistAction, itemId: String) {
        updateItemIsAdded(itemId: itemId, isAdded: action == .add)
    }
    
    private func handleDidPerform(action: CollectionWishlistAction, itemId: String) {
        guard pendingAnalyticsWishlistActions[itemId] == action else {
            return
        }
        
        pendingAnalyticsWishlistActions[itemId] = nil
        
        guard let collectionSlug = sourcePayload?.slug ?? collectionSlug else {
            return
        }
        
        analytics?.trackWishlistToggled(
            collectionSlug: collectionSlug,
            itemId: itemId,
            enabled: action == .add
        )
    }

    private func handleFailPerform(action: CollectionWishlistAction, itemId: String) {
        if pendingAnalyticsWishlistActions[itemId] == action {
            pendingAnalyticsWishlistActions[itemId] = nil
        }
        updateItemIsAdded(itemId: itemId, isAdded: action != .add)
    }

    private func updateItemIsAdded(itemId: String, isAdded: Bool) {
        guard var payload = sourcePayload,
              let index = payload.items.firstIndex(where: { $0.id == itemId })
        else {
            return
        }

        payload.items[index].isAdded = isAdded
        sourcePayload = payload

        viewState = .loaded(
            viewStateBuilder.buildLoadedContentViewState(
                from: payload,
                selectedTags: selectedTags
            )
        )
    }

    private static func normalizedTagKey(from tag: String) -> String {
        tag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
    
    private func trackScreenViewedIfNeeded() {
        guard !hasTrackedScreenView else { return }
        
        hasTrackedScreenView = true
        analytics?.trackScreenViewed()
    }

}

// MARK: - WishlistObserver

extension CollectionViewModelImpl {

    fileprivate final class WishlistObserver: ActionPerformerObserver, @unchecked Sendable {

        // MARK: - Internal Properties

        var onWillPerform: (@MainActor (CollectionWishlistAction, String) -> Void)?
        var onDidPerform: (@MainActor (CollectionWishlistAction, String) -> Void)?
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
        ) {
            Task { @MainActor [onDidPerform] in
                onDidPerform?(action, target)
            }
        }

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
