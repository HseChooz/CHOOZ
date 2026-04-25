import SwiftUI

struct CollectionFilterView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let id: String
        let tag: String
        let title: String
        let isSelected: Bool
    }
    
    // MARK: - Init
    
    init(model: Model, eventsHandler: CollectionFilterViewEventsHandler) {
        self.model = model
        self.eventsHanlder = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                eventsHanlder.toggleFilter(tag: model.tag)
            },
            label: {
                Text(model.title)
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(model.isSelected ? Colors.Common.white : Colors.Neutral.greyAB)
                    .padding(.vertical, 6.0)
                    .padding(.horizontal, 12.0)
                    .frame(height: 31.0)
                    .background(model.isSelected ? Colors.Neutral.grey900 : Colors.Neutral.greyEE)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHanlder: CollectionFilterViewEventsHandler
    
}
