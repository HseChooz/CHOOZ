import UIKit
import SwiftUI

@MainActor
struct AuthorizationFactory {
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let viewModel = AuthScreenViewModel()
        let view = AuthScreenView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
}
