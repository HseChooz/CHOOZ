import SwiftUI

struct WishlistErrorView: View {
    
    // MARK: - Init
    
    init(message: String, viewModel: WishlistViewModel) {
        self.message = message
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                VStack(spacing: 16.0) {
                    Text("Что-то пошло не так")
                        .font(.velaSans(size: 18.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey800)
                    
                    Text(message)
                        .font(.velaSans(size: 14.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey600)
                        .multilineTextAlignment(.center)
                }
                
                Button(
                    action: {
                        viewModel.fetchWishes()
                    },
                    label: {
                        Text("Попробовать снова")
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
        }
        .refreshable {
            await viewModel.refreshWishes()
        }
    }
    
    // MARK: - Private Properties
    
    private let message: String
    private let viewModel: WishlistViewModel
}
