import SwiftUI

struct CollectionLoadedView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let header: CollectionHeaderView.Model
        let filters: [CollectionFilterView.Model]
        let itemCards: [CollectionItemCardView.Model]
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: CollectionLoadedViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 23.0) {
            VStack(alignment: .leading, spacing: 12.0) {
                CollectionHeaderView(model: model.header)
                    .padding(.horizontal, 18.0)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 9.0) {
                        ForEach(model.filters, id: \.self) { filter in
                            CollectionFilterView(
                                model: filter,
                                eventsHandler: eventsHandler
                            )
                        }
                    }
                    .padding(.horizontal, 18.0)
                }
                .scrollIndicators(.hidden)
            }
            
            ScrollView {
                LazyVGrid(columns: Static.columns, alignment: .leading, spacing: 14.0) {
                    ForEach(model.itemCards, id: \.self) { itemCard in
                        CollectionItemCardView(
                            model: itemCard,
                            eventsHandler: eventsHandler
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 18.0)
            .refreshable {
                eventsHandler.refreshCollection()
            }
        }
        .padding(.top, 14.0)
    }
    
    // MARK: - Private Types
    
    private enum Static {
        
        static let columns = [
            GridItem(.adaptive(minimum: 160.0, maximum: 220.0), spacing: 16.0)
        ]
        
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: CollectionLoadedViewEventsHandler
    
}
