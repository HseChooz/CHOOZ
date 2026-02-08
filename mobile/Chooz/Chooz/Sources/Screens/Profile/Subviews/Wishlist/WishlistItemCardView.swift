import SwiftUI

struct WishlistItemCardView: View {
    
    // MARK: - Init
    
    init(item: WishlistItem) {
        self.item = item
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12.0) {
                imageView
                
                VStack(alignment: .leading, spacing: 4.0) {
                    titleView
                    
                    priceView
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let item: WishlistItem
    
    // MARK: - Private Views
    
    private var imageView: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 193.0)
            .overlay {
                imageContentView
            }
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
    }
    
    @ViewBuilder
    private var imageContentView: some View {
        if let image = item.image {
            image
                .resizable()
                .scaledToFill()
        } else {
            Colors.Blue.blue500
        }
    }
    
    private var titleView: some View {
        Text(item.title)
            .font(.velaSans(size: 14.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey800)
            .lineLimit(1)
    }
    
    private var priceView: some View {
        Text("\(item.price) \(item.currency.symbol)")
            .font(.velaSans(size: 14.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey600)
            .lineLimit(1)
    }
}
