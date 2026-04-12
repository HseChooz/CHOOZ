import SwiftUI

struct EventView: View {
    
    // MARK: - Init
    
    init(
        event: EventItem,
        eventsHandler: EventViewEventsHandler
    ) {
        self.event = event
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            toolbarView
            
            detailsView
            
            bottomActionsView
        }
        .padding(.top, 24.0)
        .padding(.horizontal, 16.0)
        .padding(.bottom, 16.0)
        .confirmationDialog(
            isPresented: $isDeleteConfirmationPresented,
            title: "Вы уверены, что хотите удалить событие?",
            primaryAction: ConfirmationDialogAction(title: "Оставить") {},
            destructiveAction: ConfirmationDialogAction(title: "Удалить") {
                eventsHandler.deleteEvent(id: event.id)
            }
        )
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let descriptionLineHeight: CGFloat = 22.0
        static let maxLines: Int = 8
        static let descriptionMaxHeight: CGFloat = descriptionLineHeight * CGFloat(maxLines)
    }
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    
    private let event: EventItem
    private let eventsHandler: EventViewEventsHandler
    
    @State private var isDeleteConfirmationPresented: Bool = false
    
    // MARK: - Private Views
    
    private var toolbarView: some View {
        HStack(spacing: .zero) {
            Spacer()
            
            Button(
                action: { dismiss() },
                label: {
                    Images.Icons.crossLarge
                        .foregroundStyle(Colors.Neutral.grey5b)
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(height: 24.0)
        .frame(maxWidth: .infinity)
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            Text(event.title)
                .font(.velaSans(size: 24.0, weight: .bold))
                .foregroundStyle(Colors.Common.black)
            
            dateView
            
            descriptionView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dateView: some View {
        HStack(alignment: .bottom, spacing: 8.0) {
            Text(event.fullDateString)
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey700)
            
            EventDaysRemainingView(event: event)
        }
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        if let description = event.description, !description.isEmpty {
            FadeScrollView(maxHeight: Layout.descriptionMaxHeight) {
                Text(description)
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey600)
            }
        }
    }
    
    private var bottomActionsView: some View {
        HStack(spacing: .zero) {
            EventViewBottomActionView(
                icon: Images.Icons.trash,
                action: {
                    isDeleteConfirmationPresented = true
                }
            )
            
            Spacer()
            
            EventViewBottomToggleView(
                icon: Images.Icons.notification,
                activeIcon: Images.Icons.notificationBlue,
                isActive: event.notifyEnabled,
                onToggle: { enabled in
                    eventsHandler.toggleNotification(for: event.id, enabled: enabled)
                }
            )
            
            Spacer()
            
            EventViewBottomToggleView(
                icon: Images.Icons.repeatIcon,
                activeIcon: Images.Icons.reapetIconPurple,
                isActive: event.repeatYearly,
                onToggle: { enabled in
                    eventsHandler.toggleRepeatYearly(for: event.id, enabled: enabled)
                }
            )
            
            Spacer()
            
            EventViewBottomActionView(
                icon: Images.Icons.edit,
                action: {
                    eventsHandler.editEvent(event)
                    dismiss()
                }
            )
        }
        .padding(.top, 10.0)
        .padding(.horizontal, 40.0)
    }
}
