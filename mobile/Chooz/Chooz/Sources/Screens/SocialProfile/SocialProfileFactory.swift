import UIKit
import SwiftUI

@MainActor
final class SocialProfileFactory {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, wishlistService: WishlistService) {
        self.appRouter = appRouter
        self.wishlistService = wishlistService
    }
    
    // MARK: - Internal Methods
    
    func makeScreen(userId: String) -> UIViewController {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        
        let viewModel = SocialProfileViewModel(
            userId: userId,
            wishlistService: wishlistService
        ) { [weak navigationController] in
            navigationController?.dismiss(animated: true)
        }
        let view = SocialProfileView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        hostingController.navigationItem.standardAppearance = navBarAppearance
        hostingController.navigationItem.scrollEdgeAppearance = navBarAppearance
        
        navigationController.viewControllers = [hostingController]
        
        return navigationController
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let wishlistService: WishlistService
}
