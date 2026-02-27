import SwiftUI

struct WishlistItemView: View {
    
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
        .confirmationDialog(
            isPresented: $viewModel.isDeleteConfirmationPresented,
            title: "Вы уверены, что хотите удалить желание?",
            primaryAction: ConfirmationDialogAction(title: "Отменить") {},
            destructiveAction: ConfirmationDialogAction(title: "Удалить") {
                viewModel.deleteWish()
            }
        )
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let descriptionLineHeight: CGFloat = 22.0
        static let maxLines: Int = 5
        static let descriptionMaxHeight: CGFloat = descriptionLineHeight * CGFloat(maxLines)
        static let bottomPadding: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: 14.0,
            compact: .zero
        )
    }
    
    // MARK: - Private Properties
    
    @Bindable
    private var viewModel: WishlistViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.interfaceLayout) private var interfaceLayout
    @Environment(\.openURL) private var openURL
    
    private var shareContent: String {
        var text = viewModel.selectedItem.title
        if let link = viewModel.selectedItem.link {
            text += "\n\(link)"
        }
        return text
    }
    
    // MARK: - Private Views
    
    private var imageView: some View {
        Group {
            if let imageUrl = viewModel.selectedItem.imageUrl, let url = URL(string: imageUrl) {
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
                .frame(maxHeight: Layout.descriptionMaxHeight)
            }
        }
        .padding(.horizontal, 16.0)
    }
    
    private var actionsView: some View {
        HStack(spacing: 8.0) {
            MainActionButton(
                title: "Редактировать желание",
                backgroundColor: Colors.Neutral.grey800,
                foregroundColor: Colors.Common.white,
                action: { viewModel.showEditWishForm() }
            )
            
            Button(
                action: { viewModel.showDeleteConfirmation() },
                label: {
                    Circle()
                        .fill(Colors.Neutral.grey800)
                        .frame(width: 50)
                        .overlay {
                            Images.Icons.trashWhite
                                .resizable()
                                .scaledToFill()
                                .frame(width: 22.0, height: 22.0)
                        }
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 16.0)
        .padding(.horizontal, 16.0)
        .padding(.bottom, Layout.bottomPadding.value(for: interfaceLayout))
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
        if let link = viewModel.selectedItem.link, let url = URL(string: link) {
            Button(
                action: { openURL(url) },
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
