import SwiftUI

struct MainTabUpcomingEventsSectionHeaderView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let title: String
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: MainTabUpcomingEventsSectionHeaderViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                eventsHandler.openUpcomingEvents()
            },
            label: {
                HStack(alignment: .center, spacing: .zero) {
                    HStack(alignment: .center, spacing: 6.0) {
                        Images.Icons.calendar
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .foregroundStyle(Colors.Neutral.grey800)
                            .frame(width: 15.0, height: 15.0)
                        
                        Text(model.title)
                            .font(.velaSans(size: 20.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey800)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey800)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
        )
        .buttonStyle(.plain)
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: MainTabUpcomingEventsSectionHeaderViewEventsHandler
    
}
