import SwiftUI

struct SocialWishlistItemView: View {
    
    // MARK: - Init
    
    init(item: WishlistItem) {
        self.item = item
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            imageView
                .overlay(alignment: .bottomTrailing) {
                    linkButtonView
                        .padding(.trailing, 16.0)
                        .padding(.bottom, 19.0)
                }
                
            detailsView
        }
        .padding(.bottom, 14.0)
        .overlay(alignment: .topTrailing) {
            toolbarView
                .padding(.top, 16.0)
                .padding(.trailing, 16.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let descriptionLineHeight: CGFloat = 22.0
        static let maxLines: Int = 5
        static let descriptionMaxHeight: CGFloat = descriptionLineHeight * CGFloat(maxLines)
    }
    
    // MARK: - Private Properties
    
    private let item: WishlistItem
    
    @Environment(\.dismiss) private var dismiss
    
    private var shareContent: String {
        var text = item.title
        if let link = item.link {
            text += "\n\(link)"
        }
        return text
    }
    
    // MARK: - Private Views
    
    private var imageView: some View {
        Group {
            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
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
        .frame(height: 387.0)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    private var imagePlaceholder: some View {
        Colors.Neutral.grey200
    }
    
    private var detailsView: some View {
        VStack(spacing: 20.0) {
            HStack(spacing: .zero) {
                Text(item.title)
                    .font(.velaSans(size: 24.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey900)
                
                Spacer()
                
                if let price = item.price,
                   let currency = item.currency {
                    Text("\(price) \(currency.symbol)")
                        .font(.velaSans(size: 24.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey600)
                }
            }
            
            if let description = item.description, !description.isEmpty {
                ScrollView {
                    Text(description)
                        .font(.velaSans(size: 16.0, weight: .semiBold))
                        .foregroundStyle(Colors.Neutral.grey500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: Layout.descriptionMaxHeight)
            }
        }
        .padding(.horizontal, 16.0)
    }
    
    private var toolbarView: some View {
        HStack(spacing: 16.0) {
            ShareLink(item: shareContent) {
                Images.Icons.share
                    .resizable()
                    .scaledToFill()
            }
            .buttonStyle(ScaleButtonStyle())
            
            Button(action: { dismiss() }) {
                Images.Icons.crossLarge
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(Colors.Neutral.grey600)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(width: 64.0, height: 24.0)
    }
    
    @ViewBuilder
    private var linkButtonView: some View {
        if item.link != nil {
            Button(
                action: { },
                label: {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Colors.Blue.blue500)
                        .frame(width: 44.0, height: 32.0)
                        .overlay {
                            Images.Icons.arrowUp
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20.0, height: 20.0)
                        }
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
    }
}
