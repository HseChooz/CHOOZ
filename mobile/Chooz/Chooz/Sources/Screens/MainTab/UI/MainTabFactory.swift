import SwiftUI
import UIKit
import Apollo

@MainActor
protocol MainTabFactoryDeps:
    MainTabRouterDeps,
    MainTabInteractorDeps
{}

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
        let viewModel = MainTabViewModelImpl(
            router: router,
            interactor: interactor,
            viewStateBuilder: viewStateBuilder
        )
        let rootView = MainTabView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)
        let navigationController = UINavigationController(rootViewController: hostingController)
        
        configureNavigationBarAppearance(for: navigationController)
        
        return navigationController
    }
    
    // MARK: - Private Methods
    
    private func configureNavigationBarAppearance(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = nil
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Private Properties
    
    private let deps: MainTabFactoryDeps
    
}
