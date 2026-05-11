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
            if let emptyStateTitle = model.emptyStateTitle {
                emptyStateView(title: emptyStateTitle)
            } else {
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
        }
        .padding(.vertical, 18.0)
        .refreshable {
            eventsHandler.refreshSections()
        }
    }
    
    // MARK: - Private Properties
    
    private let model: MainTabViewState.LoadedModel
    private let eventsHandler: MainTabLoadedViewEventsHandler
    
    // MARK: - Private Methods
    
    private func emptyStateView(title: String) -> some View {
        Text(title)
            .font(.velaSans(size: 18.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey800)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 52.0)
            .padding(.top, 80.0)
    }
    
}
