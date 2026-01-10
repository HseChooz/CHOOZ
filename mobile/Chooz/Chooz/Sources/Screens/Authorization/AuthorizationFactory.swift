import UIKit
import SwiftUI

@MainActor
struct AuthorizationFactory {
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let viewModel = AuthorizationViewModel()
        let view = AuthorizationView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
}
