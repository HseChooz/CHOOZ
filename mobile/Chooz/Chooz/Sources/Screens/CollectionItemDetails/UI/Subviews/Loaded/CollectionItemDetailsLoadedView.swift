import SwiftUI

struct CollectionItemDetailsLoadedView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let collectionItemId: String
        let imageUrl: URL?
        let wishUrl: URL?
        let title: String
        let priceText: String
        let description: String
        let isAdded: Bool
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: CollectionItemDetailsLoadedViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
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
                
            VStack(alignment: .leading, spacing: 20.0) {
                HStack(spacing: .zero) {
                    Text(model.title)
                        .font(.velaSans(size: 24.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey900)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(model.priceText)
                        .font(.velaSans(size: 24.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey600)
                        .lineLimit(1)
                }
                
                FadeScrollView {
                    Text(model.description)
                        .font(.velaSans(size: 16.0, weight: .semiBold))
                        .foregroundStyle(Colors.Neutral.grey500)
                        .lineLimit(6)
                }
            }
            .padding(.horizontal, 16.0)
            
            actionsView
                .padding(.top, 16.0)
                .padding(.bottom, 14.0)
                .padding(.horizontal, 16.0)
        }
        .confirmationDialog(
            isPresented: $isDeleteConfirmationPresented,
            title: "Вы уверены, что хотите удалить желание?",
            primaryAction: ConfirmationDialogAction(title: "Отменить") {},
            destructiveAction: ConfirmationDialogAction(title: "Удалить") {
                eventsHandler.removeFromWishlist(collectionItemId: model.collectionItemId)
            }
        )
        .overlay(alignment: .topTrailing) {
            toolbarView
                .padding(.top, 16.0)
                .padding(.trailing, 16.0)
        }
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: CollectionItemDetailsLoadedViewEventsHandler
    
    @State private var isDeleteConfirmationPresented = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    // MARK: - Private Views
    
    private var imageView: some View {
        Colors.Neutral.grey200
            .overlay {
                CachedAsyncImage(url: model.imageUrl) {
                    Colors.Neutral.grey200
                }
                .scaledToFill()
            }
            .frame(height: 387.0)
    }
    
    @ViewBuilder
    private var actionsView: some View {
        if model.isAdded {
            MainActionButton(
                title: "Удалить из вишлиста",
                backgroundColor: Colors.Neutral.grey800,
                foregroundColor: Colors.Common.white,
                action: {
                    isDeleteConfirmationPresented = true
                }
            )
        } else {
            MainActionButton(
                title: "Добавить в вишлист",
                backgroundColor: Colors.Blue.blue500,
                foregroundColor: Colors.Common.white,
                action: {
                    eventsHandler.addToWishlist(collectionItemId: model.collectionItemId)
                }
            )
        }
    }
    
    private var toolbarView: some View {
        Button(
            action: { dismiss() },
            label: {
                Images.Icons.crossLarge
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24.0, height: 24.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    @ViewBuilder
    private var linkButtonView: some View {
        if let url = model.wishUrl {
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
