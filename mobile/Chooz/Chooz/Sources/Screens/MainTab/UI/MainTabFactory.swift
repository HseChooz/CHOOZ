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
        let navigationController = MainTabNavigationController(rootViewController: hostingController)
        
        return navigationController
    }
    
    // MARK: - Private Properties
    
    private let deps: MainTabFactoryDeps
    
}

@MainActor
private final class MainTabNavigationController: UINavigationController, UINavigationControllerDelegate {

    // MARK: - Init

    override init(rootViewController: UIViewController) {
        self.mainTabViewController = rootViewController
        super.init(rootViewController: rootViewController)

        delegate = self
        setNavigationBarHidden(true, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        setNavigationBarHidden(viewController === mainTabViewController, animated: animated)
    }

    // MARK: - Private Properties

    private weak var mainTabViewController: UIViewController?

}
