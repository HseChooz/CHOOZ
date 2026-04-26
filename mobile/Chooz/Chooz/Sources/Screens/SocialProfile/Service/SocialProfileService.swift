import Foundation

protocol SocialProfileService {
    func fetchProfile(userId: String) async throws -> SocialProfilePayload
}

final class SocialProfileServiceImpl: SocialProfileService {
    
    // MARK: - Init
    
    init(wishlistService: WishlistService) {
        self.wishlistService = wishlistService
    }
    
    // MARK: - Internal Methods
    
    func fetchProfile(userId: String) async throws -> SocialProfilePayload {
        let result = try await wishlistService.fetchUserWishItems(userId: userId)
        return SocialProfilePayload(user: result.user, items: result.items)
    }
    
    // MARK: - Private Properties
    
    private let wishlistService: WishlistService
    
}
