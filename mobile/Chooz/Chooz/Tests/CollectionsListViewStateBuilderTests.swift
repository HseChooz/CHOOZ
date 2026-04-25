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
        #expect(result.collections.first?.slug == "collection-slug")
        #expect(result.collections.first?.title == "Подарки")
        #expect(result.collections.first?.subtitle == "12 товаров")
        #expect(result.collections.first?.imageUrl == URL(string: "https://example.com/image.png"))
    }
    
    @Test
    @MainActor
    func buildLoadedContentViewState_formatsItemsCountWithPluralization() {
        let payload = CollectionsListPayload(
            sectionId: "editorial",
            title: "Редакция",
            collections: [
                CollectionsListPayload.Collection(
                    id: "collection-1",
                    slug: "collection-1",
                    title: "Один",
                    subtitle: "unused",
                    badge: nil,
                    coverImageUrl: nil,
                    itemsCount: 1
                ),
                CollectionsListPayload.Collection(
                    id: "collection-2",
                    slug: "collection-2",
                    title: "Два",
                    subtitle: "unused",
                    badge: nil,
                    coverImageUrl: nil,
                    itemsCount: 2
                ),
                CollectionsListPayload.Collection(
                    id: "collection-5",
                    slug: "collection-5",
                    title: "Пять",
                    subtitle: "unused",
                    badge: nil,
                    coverImageUrl: nil,
                    itemsCount: 5
                ),
                CollectionsListPayload.Collection(
                    id: "collection-11",
                    slug: "collection-11",
                    title: "Одиннадцать",
                    subtitle: "unused",
                    badge: nil,
                    coverImageUrl: nil,
                    itemsCount: 11
                ),
                CollectionsListPayload.Collection(
                    id: "collection-21",
                    slug: "collection-21",
                    title: "Двадцать один",
                    subtitle: "unused",
                    badge: nil,
                    coverImageUrl: nil,
                    itemsCount: 21
                ),
                CollectionsListPayload.Collection(
                    id: "collection-24",
                    slug: "collection-24",
                    title: "Двадцать четыре",
                    subtitle: "unused",
                    badge: nil,
                    coverImageUrl: nil,
                    itemsCount: 24
                )
            ]
        )
        
        let result = CollectionsListViewStateBuilder().buildLoadedContentViewState(from: payload)
        
        #expect(result.collections.map(\.subtitle) == [
            "1 товар",
            "2 товара",
            "5 товаров",
            "11 товаров",
            "21 товар",
            "24 товара"
        ])
    }
    
    @Test
    @MainActor
    func buildErrorViewState_mapsUnknownErrorToScreenErrorModel() {
        let result = CollectionsListViewStateBuilder().buildErrorViewState(from: .unknown)
        
        #expect(result.title == "Произошла неизвестная ошибка")
        #expect(result.buttonTitle == "Попробовать снова")
    }
    
}
