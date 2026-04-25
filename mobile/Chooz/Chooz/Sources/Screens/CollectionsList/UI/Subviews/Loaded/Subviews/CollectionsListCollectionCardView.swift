import SwiftUI

struct CollectionsListCollectionCardView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let slug: String
        let title: String
        let subtitle: String
        let imageUrl: URL?
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: CollectionsListCollectionCardViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                eventsHandler.openCollection(with: model.slug)
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
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    
                    VStack(alignment: .leading, spacing: .zero) {
                        Text(model.title)
                            .font(.velaSans(size: 14.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey800)
                            .lineLimit(1)
                        
                        Text(model.subtitle)
                            .font(.velaSans(size: 12.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey600)
                            .lineLimit(1)
                    }
                }
                .frame(height: 254.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Views
    
    private var imagePlaceholderView: some View {
        Colors.Neutral.grey200
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: CollectionsListCollectionCardViewEventsHandler
    
}
