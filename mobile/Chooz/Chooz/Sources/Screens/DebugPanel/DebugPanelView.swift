import SwiftUI

struct DebugPanelView<ViewModel: DebugPanelViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15.0) {
                SettingsButtonView(
                    title: "Получить пуш-уведомление",
                    style: .neutral,
                    hasChevron: false,
                    action: {
                        viewModel.sendTestPush()
                    }
                )
            }
        }
        .scrollIndicators(.hidden)
        .padding(16.0)
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    
}
