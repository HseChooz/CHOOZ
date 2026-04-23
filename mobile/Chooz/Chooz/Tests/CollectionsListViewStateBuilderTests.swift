import Foundation
import Testing
@testable import Chooz

struct CollectionsListViewStateBuilderTests {
    
    @Test
    @MainActor
    func buildLoadedContentViewState_mapsPayloadToLoadedModel() {
        let payload = CollectionsListPayload(
            sectionId: "editorial",
            title: "Редакция",
            collections: [
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
        
        let result = CollectionsListViewStateBuilder().buildLoadedContentViewState(from: payload)
        
        #expect(result.title == "Редакция")
        #expect(result.collections.count == 1)
        #expect(result.collections.first?.id == "collection-1")
        #expect(result.collections.first?.title == "Подарки")
        #expect(result.collections.first?.subtitle == "Для вдохновения")
        #expect(result.collections.first?.imageUrl == URL(string: "https://example.com/image.png"))
    }
    
    @Test
    @MainActor
    func buildErrorViewState_mapsUnknownErrorToScreenErrorModel() {
        let result = CollectionsListViewStateBuilder().buildErrorViewState(from: .unknown)
        
        #expect(result.title == "Произошла неизвестная ошибка")
        #expect(result.buttonTitle == "Попробовать снова")
    }
    
}
