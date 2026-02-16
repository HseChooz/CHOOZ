import SwiftUI

struct WishlistItemCardView: View {
    
    // MARK: - Init
    
    init(item: WishlistItem, onTap: @escaping () -> Void) {
        self.item = item
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12.0) {
                imageView
                
                VStack(alignment: .leading, spacing: 4.0) {
                    titleView
                    
                    if let price = item.price, let currency = item.currency {
                        priceView(price: price, currency: currency)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let item: WishlistItem
    private let onTap: () -> Void
    
    // MARK: - Private Views
    
    private var imageView: some View {
        Colors.Neutral.grey200
            .frame(maxWidth: .infinity)
            .frame(height: 193.0)
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
    }
    
    private var titleView: some View {
        Text(item.title)
            .font(.velaSans(size: 14.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey800)
            .lineLimit(1)
    }
    
    private func priceView(price: String, currency: WishCurrency) -> some View {
        Text("\(price) \(currency.symbol)")
            .font(.velaSans(size: 14.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey600)
            .lineLimit(1)
    }
}
