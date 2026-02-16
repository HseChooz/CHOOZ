import SwiftUI

struct ProfileContentView: View {
    
    // MARK: - Init
    
    init(
        selectedSegment: ProfileSegment,
        wishlistViewModel: WishlistViewModel
    ) {
        self.selectedSegment = selectedSegment
        self.wishlistViewModel = wishlistViewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        switch selectedSegment {
        case .wishlist:
            WishlistContentView(viewModel: wishlistViewModel)
        case .questionnaire:
            // TODO: Replace with QuestionnaireContentView when available
            EmptyView()
        }
    }
    
    // MARK: - Private Properties
    
    private let selectedSegment: ProfileSegment
    private let wishlistViewModel: WishlistViewModel
}
