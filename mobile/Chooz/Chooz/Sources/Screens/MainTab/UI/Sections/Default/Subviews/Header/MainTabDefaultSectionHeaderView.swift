import SwiftUI

struct MainTabDefaultSectionHeaderView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let sectionId: String
        let title: String
    }
    
    // MARK: - Init
    
    init(
        model: Model,
        eventsHandler: MainTabDefaultSectionHeaderViewEventsHandler
    ) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                eventsHandler.openCollectionsList(with: model.sectionId)
            },
            label: {
                HStack(alignment: .center, spacing: .zero) {
                    Text(model.title)
                        .font(.velaSans(size: 20.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey800)
                        .lineLimit(1)
                    
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
    private let eventsHandler: MainTabDefaultSectionHeaderViewEventsHandler
    
}
