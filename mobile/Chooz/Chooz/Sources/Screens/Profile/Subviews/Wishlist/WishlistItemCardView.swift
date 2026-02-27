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
                    
                    priceView(price: item.price, currency: item.currency ?? .rub)
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
        Group {
            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        imagePlaceholder
                            .overlay {
                                image
                                    .resizable()
                                    .scaledToFill()
                            }
                    case .failure:
                        imagePlaceholder
                    default:
                        imagePlaceholder
                            .overlay { ProgressView() }
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 193.0)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
    }
    
    private var imagePlaceholder: some View {
        Colors.Neutral.grey200
    }
    
    private var titleView: some View {
        Text(item.title)
            .font(.velaSans(size: 14.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey800)
            .lineLimit(1)
    }
    
    private func priceView(price: String?, currency: WishCurrency) -> some View {
        let displayPrice = price.map { "\($0) \(currency.symbol)" } ?? "- \(currency.symbol)"
        return Text(displayPrice)
            .font(.velaSans(size: 14.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey600)
            .lineLimit(1)
    }
}
