import SwiftUI

struct CalendarEmptyView: View {
    
    // MARK: - Init
    
    init(eventsHandler: CalendarEmptyViewEventsHandler) {
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            Text("Вы еще не заполнили календарь")
                .font(.velaSans(size: 24.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
                .multilineTextAlignment(.center)
            
            MainActionButton(
                title: "Создать событие",
                backgroundColor: Colors.Blue.blue500,
                foregroundColor: Colors.Common.white,
                action: {
                    isEventFormPresented = true
                }
            )
        }
        .padding(.horizontal, 52.0)
        .adaptiveSheet(isPresented: $isEventFormPresented) {
            EventFormView(
                formType: .add,
                onSave: { title, description, date, link in
                    eventsHandler.saveEvent(
                        title: title,
                        description: description,
                        date: date,
                        link: link
                    )
                }
            )
        }
    }
    
    // MARK: - Private Properties
    
    private let eventsHandler: CalendarEmptyViewEventsHandler
    
    @State private var isEventFormPresented: Bool = false
}
