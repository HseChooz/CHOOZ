import Foundation
import Testing
@testable import Chooz

struct CollectionsListInteractorTests {
    
    @Test
    @MainActor
    func requestCollectionsList_returnsSectionWithRequestedId() async throws {
        let expectedSection = makePayload(sectionId: "for-partner")
        let interactor = CollectionsListInteractor(
            deps: StubCollectionsListInteractorDeps(
                collectionsListService: StubCollectionsListService(
                    sectionsResult: .success([
                        makePayload(sectionId: "editorial"),
                        expectedSection
                    ])
                )
            ),
            sectionId: "for-partner"
        )
        
        let payload = try await interactor.requestCollectionsList()
        
        #expect(payload == expectedSection)
    }
    
    @Test
    @MainActor
    func requestCollectionsList_returnsEmptyCollectionsWhenSectionIsEmpty() async throws {
        let emptySection = makePayload(sectionId: "empty", collections: [])
        let interactor = CollectionsListInteractor(
            deps: StubCollectionsListInteractorDeps(
                collectionsListService: StubCollectionsListService(
                    sectionsResult: .success([emptySection])
                )
            ),
            sectionId: "empty"
        )
        
        let payload = try await interactor.requestCollectionsList()
        
        #expect(payload.sectionId == "empty")
        #expect(payload.collections.isEmpty)
    }
    
    @Test
    @MainActor
    func requestCollectionsList_throwsUnknownWhenSectionIsMissing() async {
        let interactor = CollectionsListInteractor(
            deps: StubCollectionsListInteractorDeps(
                collectionsListService: StubCollectionsListService(
                    sectionsResult: .success([makePayload(sectionId: "editorial")])
                )
            ),
            sectionId: "missing"
        )
        
        do {
            _ = try await interactor.requestCollectionsList()
            #expect(Bool(false))
        } catch let error as CollectionsListErrorType {
            #expect(error == .unknown)
        } catch {
            #expect(Bool(false))
        }
    }
    
    @Test
    @MainActor
    func requestCollectionsList_propagatesServiceError() async {
        let interactor = CollectionsListInteractor(
            deps: StubCollectionsListInteractorDeps(
                collectionsListService: StubCollectionsListService(
                    sectionsResult: .failure(StubError.failed)
                )
            ),
            sectionId: "editorial"
        )
        
        do {
            _ = try await interactor.requestCollectionsList()
            #expect(Bool(false))
        } catch let error as StubError {
            #expect(error == .failed)
        } catch {
            #expect(Bool(false))
        }
    }
    
    // MARK: - Private Methods
    
    private func makePayload(
        sectionId: String,
        collections: [CollectionsListPayload.Collection]? = nil
    ) -> CollectionsListPayload {
        CollectionsListPayload(
            sectionId: sectionId,
            title: "Подборки",
            collections: collections ?? [
                CollectionsListPayload.Collection(
                    id: "collection-1",
                    slug: "collection-slug",
                    title: "Подарки",
                    subtitle: "Для вдохновения",
                    badge: "new",
                    coverImageUrl: URL(string: "https://example.com/image.png"),
                    itemsCount: 12
                )
            ]
        )
    }
    
}

@MainActor
private struct StubCollectionsListInteractorDeps: CollectionsListInteractorDeps {
    let collectionsListService: CollectionsListService
}

private struct StubCollectionsListService: CollectionsListService {
    let sectionsResult: Result<[CollectionsListPayload], Error>
    
    func fetchCollectionSections(search: String?) async throws -> [CollectionsListPayload] {
        try sectionsResult.get()
    }
}

private enum StubError: Error, Equatable {
    case failed
}
