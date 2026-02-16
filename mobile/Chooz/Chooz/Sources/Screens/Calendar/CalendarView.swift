import SwiftUI

struct CalendarView: View {
    
    // MARK: - Init
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Календарь")
                .font(.velaSans(size: 24, weight: .bold))
                .foregroundStyle(Colors.Common.black)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.Common.white)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Календарь")
                    .font(.velaSans(size: 24, weight: .bold))
                    .foregroundStyle(Colors.Common.black)
                    .fixedSize()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: viewModel.openProfile,
                    label: {
                        Images.Icons.profile
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36.0, height: 36.0)
                    }
                )
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: CalendarViewModel
}
