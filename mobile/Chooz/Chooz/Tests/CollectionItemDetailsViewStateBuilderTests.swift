import Foundation
import Testing
@testable import Chooz

struct CollectionItemDetailsViewStateBuilderTests {
    
    @Test
    @MainActor
    func buildLoadedContentViewState_mapsPayloadToLoadedModel() {
        let payload = CollectionItemDetailsPayload(
            id: "collection-item-1",
            wishItemId: "wish-1",
            title: "Наушники",
            description: "Беспроводные",
            link: URL(string: "https://example.com/wish"),
            price: "12990",
            currency: .rub,
            imageUrl: URL(string: "https://example.com/image.png"),
            isAdded: true
        )
        
        let result = CollectionItemDetailsViewStateBuilder().buildLoadedContentViewState(from: payload)
        
        #expect(result.collectionItemId == "collection-item-1")
        #expect(result.title == "Наушники")
        #expect(result.description == "Беспроводные")
        #expect(result.wishUrl == URL(string: "https://example.com/wish"))
        #expect(result.imageUrl == URL(string: "https://example.com/image.png"))
        #expect(result.priceText == "12990 ₽")
        #expect(result.isAdded)
    }
    
    @Test
    @MainActor
    func buildLoadedContentViewState_formatsPriceTextForSupportedCases() {
        let builder = CollectionItemDetailsViewStateBuilder()
        let cases: [(String?, WishCurrency?, String)] = [
            ("12990", .rub, "12990 ₽"),
            ("12990", nil, "12990"),
            (nil, .usd, "- $"),
            (nil, nil, "-")
        ]
        
        for (price, currency, expectedPriceText) in cases {
            let payload = CollectionItemDetailsPayload(
                id: "collection-item",
                wishItemId: nil,
                title: "Подарок",
                description: "Описание",
                link: nil,
                price: price,
                currency: currency,
                imageUrl: nil,
                isAdded: false
            )
            
            let result = builder.buildLoadedContentViewState(from: payload)
            
            #expect(result.priceText == expectedPriceText)
            #expect(result.collectionItemId == "collection-item")
            #expect(result.isAdded == false)
        }
    }
    
    @Test
    @MainActor
    func buildErrorViewState_mapsUnknownErrorToScreenErrorModel() {
        let result = CollectionItemDetailsViewStateBuilder().buildErrorViewState(from: .unknown)
        
        #expect(result.title == "Не удалось загрузить желание")
        #expect(result.buttonTitle == "Попробовать снова")
    }
    
}
