import UIKit
import Apollo
import SwiftUI

@MainActor
struct AuthorizationFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        googleAuthService: GoogleAuthService,
        toastManager: ToastManager
    ) {
        self.appRouter = appRouter
        self.googleAuthService = googleAuthService
        self.toastManager = toastManager
    }
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let interactor = AuthorizationInteractor(appRouter: appRouter, googleAuthService: googleAuthService)
        let viewModel = AuthorizationViewModel(interactor: interactor, toastManager: toastManager)
        let view = AuthorizationView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let googleAuthService: GoogleAuthService
    private let toastManager: ToastManager
    
}
