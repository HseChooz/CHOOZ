import SwiftUI

struct SocialWishlistContentView: View {
    
    // MARK: - Init
    
    init(state: WishlistState, onRetry: @escaping () -> Void) {
        self.state = state
        self.onRetry = onRetry
    }
    
    // MARK: - Body
    
    var body: some View {
        switch state {
        case .loading:
            WishlistSkeletonView()
        case .loaded(let items):
            SocialWishlistLoadedView(items: items)
        case .empty:
            emptyStateView
        case .error:
            errorStateView
        }
    }
    
    // MARK: - Private Properties
    
    private let state: WishlistState
    private let onRetry: () -> Void
    
    // MARK: - Private Views
    
    private var emptyStateView: some View {
        ScrollView {
            Text("Вишлист пуст")
                .font(.velaSans(size: 18.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
                .padding(.top, 41.0)
        }
    }
    
    private var errorStateView: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                Text("Что-то пошло не так")
                    .font(.velaSans(size: 18.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)
                
                Button(action: onRetry) {
                    Text("Попробовать снова")
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Common.white)
                }
                .buttonStyle(ScaleButtonStyle())
                .frame(height: 50.0)
                .frame(maxWidth: .infinity)
                .background(Colors.Blue.blue500)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
            .padding(.top, 41.0)
            .padding(.horizontal, 52.0)
        }
    }
}
