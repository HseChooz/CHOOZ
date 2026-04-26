import Foundation
import UIKit
import SwiftUI

@MainActor
protocol SocialProfileRouterDeps {
    var appRouter: AppRouter { get }
}

enum SocialProfileDestination {
    case wishlistItem(WishlistItem)
}

@MainActor
protocol SocialProfileRouter: AnyObject {
    func routeTo(destination: SocialProfileDestination)
}

@MainActor
final class SocialProfileRouterImpl: SocialProfileRouter {
    
    // MARK: - Init
    
    init(deps: SocialProfileRouterDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func routeTo(destination: SocialProfileDestination) {
        switch destination {
        case .wishlistItem(let item):
            let rootView = SocialWishlistItemView(item: item)
            let vc = UIHostingController(rootView: rootView)
            deps.appRouter.presentAdaptivePopup(vc)
        }
    }
    
    // MARK: - Private Properties
    
    private let deps: SocialProfileRouterDeps
    
}
