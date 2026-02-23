import SwiftUI

struct WishlistEmptyStateView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                Text("Здесь пока пусто")
                    .font(.velaSans(size: 18.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)
                
                Button(
                    action: {
                        viewModel.showCreateWishForm()
                    },
                    label: {
                        Text("Добавить желание")
                            .font(.velaSans(size: 16.0, weight: .bold))
                            .foregroundStyle(Colors.Common.white)
                            .frame(height: 50.0)
                            .frame(maxWidth: .infinity)
                            .background(Colors.Blue.blue500)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                )
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.top, 41.0)
            .padding(.horizontal, 52.0)
        }
        .refreshable {
            await viewModel.refreshWishes()
        }
        .adaptiveSheet(isPresented: $viewModel.isWishFormSheetPresented) {
            WishlistFormView(viewModel: viewModel)
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
}
