import SwiftUI

struct CalendarEmptyView: View {
    
    // MARK: - Init
    
    init(eventsHandler: CalendarEmptyViewEventsHandler) {
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            VStack(spacing: 16.0) {
                Text("Вы еще не заполнили календарь")
                    .font(.velaSans(size: 24.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)
                
                Text("Какой-то текст")
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey600)
            }
            .multilineTextAlignment(.center)
            
            MainActionButton(
                title: "Создать событие",
                backgroundColor: Colors.Blue.blue500,
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
