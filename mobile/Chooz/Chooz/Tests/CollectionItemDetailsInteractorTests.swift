import Foundation
import Testing
@testable import Chooz

struct CollectionItemDetailsInteractorTests {
    
    @Test
    @MainActor
    func requestCollectionItemDetails_returnsPayloadFromService() async throws {
        let expectedPayload = makePayload(id: "wish-42")
        let service = SpyCollectionItemDetailsService(result: .success(expectedPayload))
        let interactor = CollectionItemDetailsInteractor(
            deps: StubCollectionItemDetailsInteractorDeps(collectionItemDetailsService: service),
            collectionSlug: "for-second-half",
            itemId: "wish-42"
        )
        
        let payload = try await interactor.requestCollectionItemDetails()
        
        #expect(payload == expectedPayload)
        #expect(service.requestedCollectionSlug == "for-second-half")
        #expect(service.requestedItemId == "wish-42")
    }
    
    @Test
    @MainActor
    func requestCollectionItemDetails_propagatesServiceError() async {
        let service = SpyCollectionItemDetailsService(result: .failure(StubError.failed))
        let interactor = CollectionItemDetailsInteractor(
            deps: StubCollectionItemDetailsInteractorDeps(collectionItemDetailsService: service),
            collectionSlug: "for-second-half",
            itemId: "wish-13"
        )
        
        do {
            _ = try await interactor.requestCollectionItemDetails()
            #expect(Bool(false))
        } catch let error as StubError {
            #expect(error == .failed)
            #expect(service.requestedCollectionSlug == "for-second-half")
            #expect(service.requestedItemId == "wish-13")
        } catch {
            #expect(Bool(false))
        }
    }
    
    // MARK: - Private Methods
    
    private func makePayload(id: String) -> CollectionItemDetailsPayload {
        CollectionItemDetailsPayload(
            id: id,
            wishItemId: "wish-item-\(id)",
            title: "Подарок",
            description: "Описание",
            link: URL(string: "https://example.com/wish"),
            price: "1990",
            currency: .rub,
            imageUrl: URL(string: "https://example.com/image.png"),
            isAdded: true
        )
    }
    
}

@MainActor
private struct StubCollectionItemDetailsInteractorDeps: CollectionItemDetailsInteractorDeps {
    let collectionItemDetailsService: CollectionItemDetailsService
}

@MainActor
private final class SpyCollectionItemDetailsService: CollectionItemDetailsService {
    
    // MARK: - Init
    
    init(result: Result<CollectionItemDetailsPayload, Error>) {
        self.result = result
    }
    
    // MARK: - Internal Properties
    
    private(set) var requestedCollectionSlug: String?
    private(set) var requestedItemId: String?
    
    // MARK: - CollectionItemDetailsService
    
    func fetchCollectionItemDetails(collectionSlug: String, itemId: String) async throws -> CollectionItemDetailsPayload {
        requestedCollectionSlug = collectionSlug
        requestedItemId = itemId
        return try result.get()
    }
    
    // MARK: - Private Properties
    
    private let result: Result<CollectionItemDetailsPayload, Error>
    
}

private enum StubError: Error, Equatable {
    case failed
}
