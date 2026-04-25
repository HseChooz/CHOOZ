import SwiftUI

struct CalendarLoadedView: View {
    
    // MARK: - Init
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            ScrollView {
                LazyVStack(spacing: 8.0) {
                    if viewModel.isInfoBannerPresented {
                        InfoBannerView(
                            model: InfoBannerView.Model(
                                title: "Поделитесь своим мнением о приложении",
                                mainAction: {
                                    viewModel.markAsClicked()
                                    if let url = Static.evalLink {
                                        openURL(url)
                                    }
                                },
                                closeAction: {
                                    viewModel.markAsClicked()
                                }
                            )
                        )
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        .padding(.bottom, 16.0)
                    }
                    
                    ForEach(viewModel.events) { event in
                        eventRowView(for: event)
                    }
                }
                .padding(.top, 24.0)
                .padding(.horizontal, 16.0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isInfoBannerPresented)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                viewModel.getEvents(force: true)
            }
            
            MainActionButton(
                title: "Создать событие",
                backgroundColor: Colors.Neutral.grey800,
                foregroundColor: Colors.Common.white,
                action: {
                    viewModel.clearPendingEdit()
                    viewModel.isEventFormPresented = true
                }
            )
            .padding(16.0)
        }
        .adaptiveSheet(
            isPresented: $viewModel.isEventFormPresented,
            onDismiss: { viewModel.clearPendingEdit() }
        ) {
            EventFormView(
                formType: viewModel.eventFormType,
                onSave: { title, description, date, link in
                    viewModel.saveEvent(
                        title: title,
                        description: description,
                        date: date,
                        link: link
                    )
                }
            )
        }
        .adaptiveSheet(
            item: $viewModel.selectedEvent,
            onDismiss: {
                if viewModel.pendingEditEvent != nil {
                    viewModel.isEventFormPresented = true
                }
            }
        ) { event in
            EventView(
                event: event,
                eventsHandler: viewModel
            )
            .id("\(event.id)-\(event.notifyEnabled)-\(event.repeatYearly)")
        }
    }
    
    // MARK: - Private Types
    
    enum Static {
        
        static let evalLink: URL? = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSetkxJYjFc0kthnIx1VUZUGOQNdkTadsITgm4ptjqpcbqcypQ/viewform?usp=dialog")
        
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: CalendarViewModel
    
    @Environment(\.openURL) private var openURL
        
    // MARK: - Private Methods
    
    private func eventRowView(for event: EventItem) -> some View {
        Button(
            action: { viewModel.selectedEvent = event },
            label: {
                CalendarEventRowView(
                    model: CalendarEventRowView.Model(
                        title: event.title,
                        shortMonthString: event.shortMonthString,
                        dayString: event.dayString,
                        daysRemainingString: event.daysRemainingString
                    )
                )
            }
        )
        .buttonStyle(ScaleButtonStyle())
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
    
}
