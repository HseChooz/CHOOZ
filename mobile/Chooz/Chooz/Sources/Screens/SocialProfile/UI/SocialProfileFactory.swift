import UIKit
import SwiftUI

@MainActor
protocol SocialProfileScreenBuilding {
    func makeScreen(userId: String) -> UIViewController
}

@MainActor
struct SocialProfileFactory: SocialProfileScreenBuilding {
    
    // MARK: - Init
    
    init(deps: SocialProfileFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen(userId: String) -> UIViewController {
        let interactor = SocialProfileInteractor(
            deps: deps,
            userId: userId
        )
        let router = SocialProfileRouterImpl(deps: deps)
        let viewStateBuilder = SocialProfileViewStateBuilder()
        let analytics = SocialProfileAnalytics(analyticsService: deps.analyticsService)
        let viewModel = SocialProfileViewModelImpl(
            interactor: interactor,
            router: router,
            viewStateBuilder: viewStateBuilder,
            analytics: analytics
        )
        let rootView = SocialProfileView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    // MARK: - Private Properties
    
    private let deps: SocialProfileFactoryDeps
    
}
