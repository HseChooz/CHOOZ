import UIKit
import SwiftUI

final class AppCoordinator: BaseCoordinator<UINavigationController> {
    
    // MARK: - Init
    
    init(window: UIWindow, appContainer: AppContainer) {
        self.window = window
        self.appContainer = appContainer
        
        let presenter = UINavigationController()
        presenter.isToolbarHidden = true
        
        super.init(presenter: presenter)
        
        self.window.rootViewController = presenter
        self.window.makeKeyAndVisible()
    }
    
    // MARK: - Internal Methods
    
    override func start() {
        let vc = appContainer.authScreenFactory.makeScreen()
        presenter.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Private Properties
    
    private let window: UIWindow
    private let appContainer: AppContainer
}
