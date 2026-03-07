import SwiftUI
import Observation

@MainActor
@Observable
final class SocialProfileViewModel {
    
    // MARK: - Init
    
    init(userId: String, wishlistService: WishlistService, onClose: @escaping () -> Void) {
        self.userId = userId
        self.wishlistService = wishlistService
        self.onClose = onClose
    }
    
    // MARK: - Internal Properties
    
    let userId: String
    let onClose: () -> Void
    
    var headerModel: ProfileHeaderView.Model {
        ProfileHeaderView.Model(
            firstName: firstName,
            lastName: lastName,
            isLoading: isLoading
        )
    }
    
    var selectedSegment: ProfileSegment = .wishlist
    
    var wishlistState: WishlistState {
        if isLoading {
            return .loading
        }
        if errorMessage != nil {
            return .error
        }
        return items.isEmpty ? .empty : .loaded(items)
    }
    
    // MARK: - Internal Methods
    
    func fetchWishItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await wishlistService.fetchUserWishItems(userId: userId)
            firstName = result.user.firstName
            lastName = result.user.lastName
            items = result.items
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Private Properties
    
    private let wishlistService: WishlistService
    private var firstName: String?
    private var lastName: String?
    private var items: [WishlistItem] = []
    private var isLoading: Bool = false
    private var errorMessage: String?
}
