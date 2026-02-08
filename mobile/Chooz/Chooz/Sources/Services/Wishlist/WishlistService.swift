import SwiftUI
import Observation

@MainActor
@Observable
final class WishlistService {
    
    // MARK: - Internal Properties
    
    private(set) var wishes: [WishlistItem] = mockWishes
    
    // MARK: - Internal Methods
    
    func addWish(
        title: String,
        image: Image?,
        description: String,
        link: String?,
        price: String,
        currency: WishCurrency,
    ) async {
        let item = WishlistItem(
            id: UUID().uuidString,
            image: image,
            title: title,
            description: description,
            link: link,
            price: price,
            currency: currency
        )
        
        // TODO: Send GraphQL mutation to backend
        // e.g. let result = try await apolloClient.perform(mutation: CreateWishMutation(...))
        
        wishes.insert(item, at: 0)
    }
    
    // MARK: - Private Static
    
    static private let mockWishes: [WishlistItem] = [
        WishlistItem(id: "1", image: nil, title: "Наушники Sony WH-1000XM5", description: nil, link: nil, price: "32 000", currency: .rub),
        WishlistItem(id: "2", image: nil, title: "Кроссовки Nike Air Max", description: nil, link: nil, price: "15 990", currency: .rub),
        WishlistItem(id: "3", image: nil, title: "Книга «Чистый код»", description: nil, link: nil, price: "890", currency: .rub),
        WishlistItem(id: "4", image: nil, title: "Подписка на Spotify на год", description: nil, link: nil, price: "1 190", currency: .rub),
        WishlistItem(id: "5", image: nil, title: "Рюкзак Fjällräven Kånken", description: nil, link: nil, price: "7 500", currency: .rub),
        WishlistItem(id: "6", image: nil, title: "Набор маркеров для скетчинга", description: nil, link: nil, price: "3 200", currency: .rub),
        WishlistItem(id: "7", image: nil, title: "Apple AirTag", description: nil, link: nil, price: "45", currency: .usd),
        WishlistItem(id: "8", image: nil, title: "Термокружка Stanley", description: nil, link: nil, price: "4 800", currency: .rub),
        WishlistItem(id: "9", image: nil, title: "Сертификат в IKEA", description: nil, link: nil, price: "100", currency: .eur),
        WishlistItem(id: "10", image: nil, title: "Механическая клавиатура Keychron K2", description: nil, link: nil, price: "8 990", currency: .rub),
    ]
}
