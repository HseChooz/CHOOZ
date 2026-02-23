import SwiftUI

struct WishlistFormPriceView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: .zero) {
            HStack(spacing: 4.0) {
                Text(viewModel.selectedCurrency.symbol)
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Common.black)
                
                TextField(
                    "",
                    text: $viewModel.price,
                    prompt:
                        Text("Цена")
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey600)
                )
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey600)
                .keyboardType(.decimalPad)
            }
            
            Spacer()
            
            currencyPickerView
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
    
    // MARK: - Private Views
    
    private var currencyPickerView: some View {
        Menu {
            ForEach(WishCurrency.allCases) { currency in
                Button(currency.title) {
                    viewModel.selectedCurrency = currency
                }
            }
        } label: {
            HStack(spacing: 4.0) {
                Text(viewModel.selectedCurrency.title)
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)
                
                Images.Icons.dropdown
                    .foregroundStyle(Colors.Neutral.grey800)
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 10.0)
            .background(Colors.Common.white)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .overlay {
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(Colors.Neutral.grey200, lineWidth: 1.0)
            }
        }
    }
}
