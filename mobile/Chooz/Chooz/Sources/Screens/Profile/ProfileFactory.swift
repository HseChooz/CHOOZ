import UIKit
import SwiftUI

@MainActor
final class ProfileFactory {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, wishlistViewModel: WishlistViewModel) {
        self.appRouter = appRouter
        self.wishlistViewModel = wishlistViewModel
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = ProfileRouter(appRouter: appRouter)
        let viewModel = ProfileViewModel(router: router, wishlistViewModel: wishlistViewModel)
        let view = ProfileView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        
        return hostingController
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let wishlistViewModel: WishlistViewModel
}
