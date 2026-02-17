import SwiftUI

struct EventDaysRemainingView: View {
    
    // MARK: - Init
    
    init(event: EventItem) {
        self.event = event
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(event.daysRemainingString)
            .font(.velaSans(size: 12.0, weight: .semiBold))
            .foregroundStyle(Colors.Blue.blue500)
            .padding(.top, 2.0)
            .padding(.horizontal, 6.0)
            .padding(.bottom, 4.0)
            .background(Colors.Blue.blue100)
            .clipShape(RoundedRectangle(cornerRadius: 7.0))
    }
    
    // MARK: - Private Properties
    
    private let event: EventItem
}
