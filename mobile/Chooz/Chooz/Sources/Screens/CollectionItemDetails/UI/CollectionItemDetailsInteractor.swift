import Foundation

@MainActor
protocol CollectionItemDetailsInteractorDeps {
    var collectionItemDetailsService: CollectionItemDetailsService { get }
}

@MainActor
final class CollectionItemDetailsInteractor {
    
    // MARK: - Init
    
    init(
        deps: CollectionItemDetailsInteractorDeps,
        collectionSlug: String,
        itemId: String
    ) {
        self.deps = deps
        self.collectionSlug = collectionSlug
        self.itemId = itemId
    }
    
    // MARK: - Internal Methods
    
    func requestCollectionItemDetails() async throws -> CollectionItemDetailsPayload {
        try await deps.collectionItemDetailsService.fetchCollectionItemDetails(
            collectionSlug: collectionSlug,
            itemId: itemId
        )
    }
    
    // MARK: - Private Properties
    
    private let deps: CollectionItemDetailsInteractorDeps
    private let collectionSlug: String
    private let itemId: String
    
}
