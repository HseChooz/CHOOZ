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
                    ForEach(viewModel.events) { event in
                        eventRowView(for: event)
                    }
                }
                .padding(.top, 24.0)
                .padding(.horizontal, 16.0)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                viewModel.getEvents()
            }
            
            MainActionButton(
                title: "Создать событие",
                backgroundColor: Colors.Neutral.grey800,
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
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: CalendarViewModel
        
    // MARK: - Private Methods
    
    private func eventRowView(for event: EventItem) -> some View {
        Button(
            action: { viewModel.selectedEvent = event },
            label: {
                HStack(spacing: 16.0) {
                    dateView(event)
                    
                    dividerView
                    
                    detailsView(event)
                    
                    Spacer()
                }
                .padding(.vertical, 10.0)
                .padding(.horizontal, 16.0)
                .frame(height: 80.0)
                .frame(maxWidth: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: 20.0))
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 20.0)
                        .stroke(Colors.Neutral.grey200, lineWidth: 1.0)
                }
            }
        )
        .buttonStyle(ScaleButtonStyle())
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
    
    private func dateView(_ event: EventItem) -> some View {
        VStack(alignment: .center, spacing: .zero) {
            Text(event.shortMonthString)
                .font(.velaSans(size: 14.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey600)
            
            Text(event.dayString)
                .font(.velaSans(size: 24.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
        }
        .frame(width: 40.0)
    }
    
    private func detailsView(_ event: EventItem) -> some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Text(event.title)
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
            
            EventDaysRemainingView(event: event)
        }
    }
    
    // MARK: - Private Views
    
    private var dividerView: some View {
        Rectangle()
            .fill(Colors.Neutral.grey400)
            .frame(width: 1.0)
    }
}
