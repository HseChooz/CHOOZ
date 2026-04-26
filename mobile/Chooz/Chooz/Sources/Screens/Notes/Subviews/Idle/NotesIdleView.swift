import SwiftUI

struct NotesIdleView: View {

    // MARK: - Init

    init(eventsHandler: NotesIdleViewEventsHandler) {
        self.eventsHandler = eventsHandler
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24.0) {
            VStack(spacing: 8.0) {
                Text("Здесь пока пусто")
                    .font(.velaSans(size: 18.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)

                Text("Создавайте заметки, чтобы точно не забыть о предпочтениях своих близких")
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey500)
                    .multilineTextAlignment(.center)
            }

            MainActionButton(
                title: "Создать заметку",
                backgroundColor: Colors.Blue.blue500,
                foregroundColor: Colors.Common.white,
                action: eventsHandler.createNote
            )
        }
        .padding(.horizontal, 52.0)
    }

    // MARK: - Private Properties

    private let eventsHandler: NotesIdleViewEventsHandler

}
