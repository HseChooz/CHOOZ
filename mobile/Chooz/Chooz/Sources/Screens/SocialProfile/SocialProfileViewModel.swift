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
            firstName: nil,
            lastName: nil,
            isLoading: false
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
            items = try await wishlistService.fetchUserWishItems(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Private Properties
    
    private let wishlistService: WishlistService
    private var items: [WishlistItem] = []
    private var isLoading: Bool = false
    private var errorMessage: String?
}
