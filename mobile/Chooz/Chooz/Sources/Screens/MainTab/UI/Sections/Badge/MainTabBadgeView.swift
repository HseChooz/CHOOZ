import SwiftUI

struct MainTabBadgeView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        
        let title: String
        let subtitle: String
        let collectionId: String
        
    }
    
    // MARK: - Init
    
    init(model: Model, eventsHandler: MainTabBadgeViewEventsHandler) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                eventsHandler.openCollection(with: model.collectionId)
            },
            label: {
                HStack(alignment: .top, spacing: 8.0) {
                    Images.Icons.heart
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15.0, height: 15.0)
                        .offset(y: 3.0)
                    
                    VStack(alignment: .leading, spacing: .zero) {
                        Text(model.title)
                            .font(.velaSans(size: 14.0, weight: .bold))
                            .foregroundStyle(Colors.Pink.pink500)
                            .lineLimit(1)
                        
                        Text(model.subtitle)
                            .font(.velaSans(size: 12.0, weight: .bold))
                            .foregroundStyle(Colors.Pink.pink400)
                            .lineLimit(1)
                    }
                }
                .padding(EdgeInsets(top: 13.0, leading: 20.0, bottom: 10.0, trailing: 13.0))
                .frame(height: 57.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Colors.Pink.pink100)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 14.0)
                        .stroke(Colors.Pink.pinkF0)
                }
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let eventsHandler: MainTabBadgeViewEventsHandler
    
}
