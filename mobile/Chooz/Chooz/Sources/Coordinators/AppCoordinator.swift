import UIKit
import SwiftUI

final class AppCoordinator: BaseCoordinator<UINavigationController> {
    
    // MARK: - Init
    
    init(window: UIWindow) {
        self.window = window
        
        let presenter = UINavigationController()
        presenter.isToolbarHidden = true
        
        super.init(presenter: presenter)
        
        self.window.rootViewController = presenter
        self.window.makeKeyAndVisible()
    }
    
    // MARK: - Internal Methods
    
    override func start() {
        let view = ContentView()
        let controller = UIHostingController(rootView: view)
        presenter.setViewControllers([controller], animated: false)
    }
    
    // MARK: - Private Properties
    
    private let window: UIWindow
}
