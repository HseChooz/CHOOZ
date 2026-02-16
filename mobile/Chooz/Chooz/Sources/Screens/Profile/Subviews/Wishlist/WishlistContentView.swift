import SwiftUI

struct WishlistContentView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.fetchWishes()
            }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: WishlistViewModel
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.wishlistState {
        case .empty:
            WishlistEmptyStateView(viewModel: viewModel)
        case .loading:
            WishlistSkeletonView()
        case .loaded(let items):
            WishlistLoadedView(viewModel: viewModel, items: items)
        case .error(let message):
            WishlistErrorView(message: message, viewModel: viewModel)
        }
    }
}
