import Foundation

// MARK: - Dependencies

@MainActor
protocol CollectionWishlistActionPerformerProducerDeps {
    var collectionWishlistService: CollectionWishlistService { get }
    var toastManager: ToastManager { get }
}

// MARK: - Producer

@MainActor
final class CollectionWishlistActionPerformerProducer: Sendable {

    // MARK: - Internal Properties

    var reporter: some CollectionWishlistActionReporter {
        rootObservableActionPerformer
    }

    // MARK: - Init

    init(deps: CollectionWishlistActionPerformerProducerDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func makePerformer() -> some CollectionWishlistActionPerformer {
        rootObservableActionPerformer
            .withFailureToast(toastManager: deps.toastManager)
    }

    // MARK: - Private Properties

    private let deps: CollectionWishlistActionPerformerProducerDeps

    private lazy var rootObservableActionPerformer = CollectionWishlistBaseActionPerformer(
        service: deps.collectionWishlistService
    ).coordinated()

}

// MARK: - Base Action Performer

private final class CollectionWishlistBaseActionPerformer: ActionPerformer {

    // MARK: - Init

    init(service: CollectionWishlistService) {
        self.service = service
    }

    // MARK: - Internal Methods

    func perform(action: CollectionWishlistAction, for target: String) async throws {
        try Task.checkCancellation()

        switch action {
        case .add:
            try await service.addToWishlist(collectionItemId: target)
        case .remove:
            try await service.removeFromWishlist(collectionItemId: target)
        }
    }

    // MARK: - Private Properties

    private let service: CollectionWishlistService

}
