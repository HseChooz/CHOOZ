import SwiftUI

struct WishView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
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
                
            actionsView
        }
        .overlay(alignment: .topTrailing) {
            toolbarView
                .padding(.top, 16.0)
                .padding(.trailing, 16.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
    }
    
    // MARK: - Private Types
    
    private enum Static {
        static let descriptionLineHeight: CGFloat = 22.0
        static let maxLines: Int = 5
        static let descriptionMaxHeight: CGFloat = descriptionLineHeight * CGFloat(maxLines)
    }
    
    // MARK: - Private Properties
    
    private let viewModel: WishlistViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    private var shareContent: String {
        var text = viewModel.selectedItem.title
        if let link = viewModel.selectedItem.link {
            text += "\n\(link)"
        }
        return text
    }
    
    // MARK: - Private Views
    
    private var imageView: some View {
        Colors.Neutral.grey200
            .frame(height: 387.0)
            .frame(maxWidth: .infinity)
    }
    
    private var detailsView: some View {
        VStack(spacing: 20.0) {
            HStack(spacing: .zero) {
                Text(viewModel.selectedItem.title)
                    .font(.velaSans(size: 24.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey900)
                
                Spacer()
                
                if let price = viewModel.selectedItem.price,
                   let currency = viewModel.selectedItem.currency {
                    Text("\(price) \(currency.symbol)")
                        .font(.velaSans(size: 24.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey600)
                }
            }
            
            if let description = viewModel.selectedItem.description, !description.isEmpty {
                ScrollView {
                    Text(description)
                        .font(.velaSans(size: 16.0, weight: .semiBold))
                        .foregroundStyle(Colors.Neutral.grey500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: Static.descriptionMaxHeight)
            }
        }
        .padding(.horizontal, 16.0)
    }
    
    private var actionsView: some View {
        HStack(spacing: 8.0) {
            Button(
                action: { viewModel.showEditWishForm() },
                label: {
                    Text("Редактировать желание")
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Common.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50.0)
                        .background(Colors.Neutral.grey800)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            )
            .buttonStyle(ScaleButtonStyle())
            
            Button(
                action: {},
                label: {
                    Circle()
                        .fill(Colors.Neutral.grey800)
                        .frame(width: 50)
                        .overlay {
                            HStack(spacing: 5.0) {
                                ForEach(1...3, id: \.self) { _ in
                                    Circle()
                                        .fill(Colors.Common.white)
                                        .frame(width: 5)
                                }
                            }
                        }
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 16.0)
        .padding(.horizontal, 16.0)
        .padding(.bottom, 14.0)
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
