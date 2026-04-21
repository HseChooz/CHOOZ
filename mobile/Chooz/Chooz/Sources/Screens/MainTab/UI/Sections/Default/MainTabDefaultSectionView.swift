import SwiftUI

struct MainTabDefaultSectionView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let headerModel: MainTabDefaultSectionHeaderView.Model
        let collectionCards: [MainTabDefaultSectionCollectionCardView.Model]
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: MainTabDefaultSectionViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12.0) {
            MainTabDefaultSectionHeaderView(
                model: model.headerModel,
                eventsHandler: eventsHandler
            )
            .padding(.horizontal, 18.0)
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 18.0) {
                    ForEach(model.collectionCards, id: \.self) { collectionCard in
                        MainTabDefaultSectionCollectionCardView(
                            model: collectionCard,
                            eventsHandler: eventsHandler
                        )
                    }
                }
                .padding(.horizontal, 18.0)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: MainTabDefaultSectionViewEventsHandler
    
}
