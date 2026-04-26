import UIKit

@MainActor
final class AppRouter {

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Internal Properties

    weak var activeTabNavigationController: UINavigationController?
    weak var appTabBarController: AppTabBarController?

    var topViewController: UIViewController? {
        let nav = activeNavigationController
        return nav.topViewController ?? nav
    }

    // MARK: - Internal Methods

    func setRoot(_ viewController: UIViewController, animated: Bool = false) {
        navigationController.setViewControllers([viewController], animated: animated)
    }

    func push(_ viewController: UIViewController, animated: Bool = true, hideBackButton: Bool = false) {
        if hideBackButton {
            viewController.navigationItem.hidesBackButton = true
        }
        activeNavigationController.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool = true) {
        _ = activeNavigationController.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        _ = activeNavigationController.popToRootViewController(animated: animated)
    }

    func present(_ viewController: UIViewController, animated: Bool = true) {
        topViewController?.present(viewController, animated: animated)
    }

    func selectTab(_ tab: AppTab, popToRoot: Bool = false) {
        appTabBarController?.selectTab(tab, popToRoot: popToRoot)
    }

    func presentAdaptivePopup(_ viewController: UIViewController, animated: Bool = true) {
        guard let topViewController else {
            return
        }

        let currentInterfaceLayout = topViewController.currentInterfaceLayout
        let targetWidth: CGFloat = currentInterfaceLayout.isLarge ? 440.0 : topViewController.view.bounds.width
        let targetHeight = viewController.view.sizeThatFits(
            CGSize(width: targetWidth, height: .infinity)
        ).height

        if currentInterfaceLayout.isLarge {
            viewController.modalPresentationStyle = .formSheet
            viewController.preferredContentSize = CGSize(width: targetWidth, height: targetHeight)
        } else {
            viewController.modalPresentationStyle = .pageSheet

            if let sheet = viewController.sheetPresentationController {
                let customDetent = UISheetPresentationController.Detent.custom { _ in
                    return targetHeight
                }
                sheet.detents = [customDetent]
                sheet.prefersGrabberVisible = true
            }
        }

        topViewController.present(viewController, animated: animated)
    }

    func replacePresentedAdaptivePopup(with viewController: UIViewController, animated: Bool = true) {
        let presenter: UIViewController
        if activeNavigationController.presentedViewController != nil {
            presenter = activeNavigationController
        } else if let topViewController = activeNavigationController.topViewController,
                  topViewController.presentedViewController != nil {
            presenter = topViewController
        } else {
            presentAdaptivePopup(viewController, animated: animated)
            return
        }

        presenter.dismiss(animated: animated) { [weak self] in
            Task { @MainActor in
                self?.presentAdaptivePopup(viewController, animated: animated)
            }
        }
    }

    // MARK: - Private Properties

    private let window: UIWindow
    private let navigationController: UINavigationController

    private var activeNavigationController: UINavigationController {
        activeTabNavigationController ?? navigationController
    }
}
