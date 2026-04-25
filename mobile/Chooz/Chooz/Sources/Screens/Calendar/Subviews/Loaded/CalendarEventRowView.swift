import SwiftUI

struct CalendarEventRowView: View {
    
    // MARK: - Internal Properties
    
    struct Model: Hashable {
        let title: String
        let shortMonthString: String
        let dayString: String
        let daysRemainingString: String
    }
    
    // MARK: - Init
    
    init(model: Model) {
        self.model = model
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16.0) {
            dateView
            
            dividerView
            
            detailsView
            
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
    
    // MARK: - Private Views
    
    private var dateView: some View {
        VStack(alignment: .center, spacing: .zero) {
            Text(model.shortMonthString)
                .font(.velaSans(size: 14.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey600)
            
            Text(model.dayString)
                .font(.velaSans(size: 24.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
        }
        .frame(width: 40.0)
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Text(model.title)
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
            
            EventDaysRemainingView(daysRemainingString: model.daysRemainingString)
        }
    }
    
    private var dividerView: some View {
        Rectangle()
            .fill(Colors.Neutral.grey400)
            .frame(width: 1.0)
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    
}
