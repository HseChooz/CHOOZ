import UIKit
import SwiftUI

@MainActor
protocol AuthorizationFactoryDeps:
    AuthorizationInteractorDeps,
    AuthorizationRouterDeps,
    AuthorizationAnalyticsDeps,
    AuthorizationViewModelDeps
{}

@MainActor
struct AuthorizationFactory {
    
    // MARK: - Init
    
    init(deps: AuthorizationFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let router = AuthorizationRouter(deps: deps)
        let interactor = AuthorizationInteractor(deps: deps)
        let analytics = AuthorizationAnalytics(deps: deps)
        let viewModel = AuthorizationViewModel(
            interactor: interactor,
            router: router,
            analytics: analytics,
            deps: deps
        )
        let view = AuthorizationView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
    // MARK: - Private Properties
    
    private let deps: AuthorizationFactoryDeps
    
}
