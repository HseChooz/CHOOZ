import Foundation

@MainActor
protocol CollectionInteractorDeps {
    var collectionService: CollectionService { get }
}

@MainActor
final class CollectionInteractor {
    
    // MARK: - Init
    
    init(
        deps: CollectionInteractorDeps,
        slug: String
    ) {
        self.deps = deps
        self.slug = slug
    }
    
    // MARK: - Internal Methods
    
    func requestCollection() async throws -> CollectionPayload {
        try await deps.collectionService.fetchCollection(slug: slug)
    }
    
    // MARK: - Private Properties
    
    private let deps: CollectionInteractorDeps
    private let slug: String
    
}
