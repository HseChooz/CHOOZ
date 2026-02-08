import SwiftUI

struct WishlistEmptyStateView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            VStack(spacing: 16.0) {
                Text("Здесь пока пусто")
                    .font(.velaSans(size: 18.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)
                
                Text("Какой-то текст")
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey600)
            }
            
            Button(
                action: {
                    viewModel.showAddWishSheet()
                },
                label: {
                    Text("Добавить желание")
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Common.white)
                }
            )
            .buttonStyle(ScaleButtonStyle())
            .frame(height: 50.0)
            .frame(maxWidth: .infinity)
            .background(Colors.Blue.blue500)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
        .padding(.top, 41.0)
        .padding(.horizontal, 52.0)
        .sheet(isPresented: $viewModel.isAddWishSheetPresented) {
            AddWishView(viewModel: viewModel)
                .presentationDetents([.height(500.0)])
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
}
