import UIKit
import SwiftUI

@MainActor
final class CalendarFactory {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, profileFactory: ProfileFactory) {
        self.appRouter = appRouter
        self.profileFactory = profileFactory
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = CalendarRouter(appRouter: appRouter, profileFactory: profileFactory)
        let viewModel = CalendarViewModel(router: router)
        let view = CalendarView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.navigationBar.prefersLargeTitles = false
        
        return navigationController
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let profileFactory: ProfileFactory
}
