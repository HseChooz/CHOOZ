import SwiftUI

struct MainTabLoadedView: View {
    
    // MARK: - Init
    
    init(
        model: MainTabViewState.LoadedModel,
        eventsHandler: MainTabLoadedViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        FadeScrollView(fadePercentage: 0.1) {
            LazyVStack(alignment: .leading, spacing: 31.0) {
                ForEach(model.sections, id: \.self) { section in
                    switch section {
                    case .upcomingEventSection(let model):
                        MainTabUpcomingEventsSectionView(model: model, eventsHandler: eventsHandler)
                    case .badgeSection(let model):
                        if let badgeModel = model {
                            MainTabBadgeView(model: badgeModel, eventsHandler: eventsHandler)
                        }
                    case .defaultSection(let model):
                        MainTabDefaultSectionView(model: model, eventsHandler: eventsHandler)
                    }
                }
            }
        }
        .padding(.vertical, 18.0)
        .refreshable {
            eventsHandler.refreshSections()
        }
    }
    
    // MARK: - Private Properties
    
    private let model: MainTabViewState.LoadedModel
    private let eventsHandler: MainTabLoadedViewEventsHandler
    
}
