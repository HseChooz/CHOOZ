import SwiftUI
import UIKit
import Apollo

@MainActor
protocol MainTabFactoryDeps:
    MainTabRouterDeps,
    MainTabInteractorDeps
{
    var analyticsService: AnalyticsService { get }
}

@MainActor
struct MainTabFactory {
    
    // MARK: - Init
    
    init(deps: MainTabFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = MainTabRouter(deps: deps)
        let interactor = MainTabInteractor(deps: deps)
        let viewStateBuilder = MainTabViewStateBuilder()
        let analytics = MainTabAnalytics(analyticsService: deps.analyticsService)
        let viewModel = MainTabViewModelImpl(
            router: router,
            interactor: interactor,
            viewStateBuilder: viewStateBuilder,
            analytics: analytics
        )
        let rootView = MainTabView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)
        
        return hostingController
    }
    
    // MARK: - Private Properties
    
    private let deps: MainTabFactoryDeps
    
}
