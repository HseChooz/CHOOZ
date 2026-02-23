import SwiftUI

struct SocialWishlistContentView: View {
    
    // MARK: - Init
    
    init(items: [WishlistItem]) {
        self.items = items
    }
    
    // MARK: - Body
    
    var body: some View {
        if items.isEmpty {
            emptyStateView
        } else {
            SocialWishlistLoadedView(items: items)
        }
    }
    
    // MARK: - Private Properties
    
    private let items: [WishlistItem]
    
    // MARK: - Private Views
    
    private var emptyStateView: some View {
        ScrollView {
            Text("Вишлист пуст")
                .font(.velaSans(size: 18.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
                .padding(.top, 41.0)
        }
    }
}
