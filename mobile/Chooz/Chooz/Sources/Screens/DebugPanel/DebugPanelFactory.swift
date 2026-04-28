import SwiftUI

@MainActor
struct DebugPanelFactory {
    
    // MARK: - Init
    
    init(deps: DebugPanelFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let viewModel = DebugPanelViewModelImpl(
            notificationService: deps.notificationService,
            toastManager: deps.toastManager
        )
        let rootView = DebugPanelView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        
        return vc
    }
    
    // MARK: - Private Properties
    
    private let deps: DebugPanelFactoryDeps
    
}
