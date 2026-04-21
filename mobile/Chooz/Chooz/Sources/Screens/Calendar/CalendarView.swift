import SwiftUI

struct CalendarView: View {
    
    // MARK: - Init
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Colors.Common.white)
            .toolbar {
                toolbarContentView
            }
            .onAppear {
                viewModel.onCalendarAppear()
            }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: CalendarViewModel
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .empty:
            CalendarEmptyView(eventsHandler: viewModel)
        case .loading:
            CalendarSkeletonView()
        case .loaded:
            CalendarLoadedView(viewModel: viewModel)
        case .error:
            CalendarErrorView(eventsHandler: viewModel)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContentView: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Календарь")
                .font(.velaSans(size: 24, weight: .bold))
                .foregroundStyle(Colors.Common.black)
                .fixedSize()
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButtonView(action: viewModel.openProfile)
        }
    }
}
