import SwiftUI

struct CollectionItemCardView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let id: String
        let title: String
        let priceText: String
        let imageUrl: URL?
        let isAdded: Bool
    }
    
    // MARK: - Init
    
    init(model: Model, eventsHandler: CollectionItemCardViewEventsHandler) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                eventsHandler.openCollectionItemDetails(itemId: model.id)
            },
            label: {
                VStack(alignment: .leading, spacing: 12.0) {
                    imagePlaceholderView
                        .frame(height: 193.0)
                        .overlay(alignment: .top) {
                            CachedAsyncImage(url: model.imageUrl) {
                                imagePlaceholderView
                            }
                        }
                        .overlay(alignment: .bottomTrailing) {
                            wishActionButtonView
                                .padding(10.0)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(model.title)
                            .font(.velaSans(size: 14.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey800)
                            .lineLimit(1)
                                                
                        Text(model.priceText)
                            .font(.velaSans(size: 14.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey600)
                            .lineLimit(1)
                    }
                }
                .frame(height: 254.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: CollectionItemCardViewEventsHandler
    
    // MARK: - Private Views
    
    private var imagePlaceholderView: some View {
        Colors.Neutral.grey200
    }
    
    @ViewBuilder
    private var wishActionButtonView: some View {
        if model.isAdded {
            deleteWishActionView
        } else {
            addWishActionView
        }
    }
    
    private var addWishActionView: some View {
        Button(
            action: { eventsHandler.toggleWishlistItem(id: model.id, isAdded: false) },
            label: {
                Text("+")
                    .font(.velaSans(size: 32.0, weight: .regular))
                    .foregroundStyle(Colors.Common.white)
                    .lineLimit(1)
                    .frame(width: 40, height: 40.0)
                    .background(Colors.Neutral.grey700)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var deleteWishActionView: some View {
        Button(
            action: { eventsHandler.toggleWishlistItem(id: model.id, isAdded: true) },
            label: {
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Colors.Red.red500)
                    .frame(width: 40.0, height: 40.0)
                    .overlay {
                        Images.Icons.trashWhite
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16.0, height: 18.0)
                    }
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
}
