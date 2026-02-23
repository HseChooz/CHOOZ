import SwiftUI
import Observation

@MainActor
@Observable
final class SocialProfileViewModel {
    
    // MARK: - Init
    
    init(userId: String, onClose: @escaping () -> Void) {
        self.userId = userId
        self.onClose = onClose
    }
    
    // MARK: - Internal Properties
    
    let userId: String
    let onClose: () -> Void
    
    var headerModel: ProfileHeaderView.Model {
        ProfileHeaderView.Model(
            firstName: mockFirstName,
            lastName: mockLastName,
            isLoading: false
        )
    }
    
    var selectedSegment: ProfileSegment = .wishlist
    
    var wishlistItems: [WishlistItem] {
        mockWishlistItems
    }
    
    // MARK: - Private Properties
    
    private let mockFirstName: String = "Алексей"
    private let mockLastName: String = "Иванов"
    
    private let mockWishlistItems: [WishlistItem] = [
        WishlistItem(
            id: "mock-1",
            title: "Наушники Sony WH-1000XM5",
            description: "Беспроводные наушники с шумоподавлением",
            link: "https://example.com/headphones",
            price: "29 990",
            currency: .rub
        ),
        WishlistItem(
            id: "mock-2",
            title: "Книга «Дюна»",
            description: nil,
            link: nil,
            price: "890",
            currency: .rub
        ),
        WishlistItem(
            id: "mock-3",
            title: "Кофемашина DeLonghi",
            description: "Автоматическая кофемашина для дома с капучинатором",
            link: "https://example.com/coffee",
            price: "45 000",
            currency: .rub
        ),
        WishlistItem(
            id: "mock-4",
            title: "Подписка на Spotify",
            description: nil,
            link: nil,
            price: nil,
            currency: nil
        ),
    ]
}
