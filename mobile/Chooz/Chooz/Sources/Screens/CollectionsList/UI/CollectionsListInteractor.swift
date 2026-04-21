import Foundation

@MainActor
protocol CollectionsListInteractorDeps {
    var collectionsListService: CollectionsListService { get }
}


@MainActor
final class CollectionsListInteractor {
    
    // MARK: - Init
    
    init(
        deps: CollectionsListInteractorDeps,
        sectionId: String
    ) {
        self.deps = deps
        self.sectionId = sectionId
    }
    
    // MARK: - Internal Methods

    func requestCollectionsList() async throws -> CollectionsListPayload {
        let sections = try await deps.collectionsListService.fetchCollectionSections(search: nil)
        
        guard let section = sections.first(where: { $0.sectionId == sectionId }) else {
            throw CollectionsListErrorType.unknown
        }
        
        return section
    }
    
    // MARK: - Private Properties

    private let deps: CollectionsListInteractorDeps
    private let sectionId: String
    
}
