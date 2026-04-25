import SwiftUI

struct MainTabUpcomingEventsSectionView: View {
    
    // MARK: - Internal Properties
    
    struct Model: Hashable {
        let headerModel: MainTabUpcomingEventsSectionHeaderView.Model
        let eventModel: CalendarEventRowView.Model
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: MainTabUpcomingEventsSectionViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12.0) {
            MainTabUpcomingEventsSectionHeaderView(
                model: model.headerModel,
                eventsHandler: eventsHandler
            )
            
            CalendarEventRowView(model: model.eventModel)
        }
        .padding(.horizontal, 18.0)
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: MainTabUpcomingEventsSectionViewEventsHandler
}
