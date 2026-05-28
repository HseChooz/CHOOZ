import UIKit
import SwiftUI

@MainActor
final class SettingsFactory {
    
    // MARK: - Init
    
    init(deps: SettingsFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = SettingsRouter(deps: deps)
        let analytics = SettingsAnalytics(analyticsService: deps.analyticsService)
        let calendarInteractor = CalendarInteractor(calendarService: deps.calendarService)
        let wishlistShareModel = WishlistShareSettingsModel(
            profileService: deps.profileService,
            toastManager: deps.toastManager,
            sharePresenter: router,
            clipboard: ClipboardWriter()
        )
        let viewModel = SettingsViewModelImpl(
            router: router,
            analytics: analytics,
            calendarInteractor: calendarInteractor,
            deps: deps
        )
        let view = SettingsView(
            viewModel: viewModel,
            wishlistShareModel: wishlistShareModel
        )
        let hostingController = UIHostingController(rootView: view)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        hostingController.navigationItem.standardAppearance = appearance
        hostingController.navigationItem.scrollEdgeAppearance = appearance
        hostingController.view.tintColor = UIColor(Colors.Blue.blue500)
        
        return hostingController
    }
    
    // MARK: - Private Properties
    
    private let deps: SettingsFactoryDeps
}
