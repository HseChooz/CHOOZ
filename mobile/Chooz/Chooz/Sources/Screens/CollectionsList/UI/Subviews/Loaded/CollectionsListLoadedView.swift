import SwiftUI

struct CollectionsListLoadedView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let title: String
        let collections: [CollectionsListCollectionCardView.Model]
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: CollectionsListLoadedViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28.0) {
            Text(model.title)
                .font(.velaSans(size: 24.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
                .lineLimit(1)
            
            ScrollView {
                LazyVGrid(columns: Static.columns, alignment: .leading, spacing: 14.0) {
                    ForEach(model.collections, id: \.self) { collection in
                        CollectionsListCollectionCardView(
                            model: collection,
                            eventsHandler: eventsHandler
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            .refreshable {
                eventsHandler.refreshCollectionsList()
            }
        }
        .padding(.horizontal, 19.0)
    }
    
    // MARK: - Private Types
    
    private enum Static {
        
        static let columns = [
            GridItem(.adaptive(minimum: 160.0, maximum: 220.0), spacing: 16.0)
        ]
        
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: CollectionsListLoadedViewEventsHandler
    
}
