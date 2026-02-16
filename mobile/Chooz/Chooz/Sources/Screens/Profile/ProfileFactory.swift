import UIKit
import SwiftUI

@MainActor
final class ProfileFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        profileService: ProfileService,
        wishlistViewModel: WishlistViewModel
    ) {
        self.appRouter = appRouter
        self.profileService = profileService
        self.wishlistViewModel = wishlistViewModel
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = ProfileRouter(appRouter: appRouter)
        let viewModel = ProfileViewModel(
            router: router,
            profileService: profileService,
            wishlistViewModel: wishlistViewModel
        )
        let view = ProfileView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        hostingController.navigationItem.standardAppearance = appearance
        hostingController.navigationItem.scrollEdgeAppearance = appearance
        
        return hostingController
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let profileService: ProfileService
    private let wishlistViewModel: WishlistViewModel
}
