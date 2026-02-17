import SwiftUI

struct CalendarErrorView: View {
    
    // MARK: - Init
    
    init(eventsHandler: CalendarErrorViewEventsHandler) {
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            VStack(spacing: 16.0) {
                Text("Что-то пошло не так")
                    .font(.velaSans(size: 24.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)
                
                Text("Не удалось загрузить события")
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey600)
            }
            .multilineTextAlignment(.center)
            
            MainActionButton(
                title: "Попробовать ещё раз",
                backgroundColor: Colors.Blue.blue500,
                action: { eventsHandler.getEvents() }
            )
        }
        .padding(.horizontal, 52.0)
    }
    
    // MARK: - Private Properties
    
    private let eventsHandler: CalendarErrorViewEventsHandler
}
