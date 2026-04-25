import Foundation
import UIKit
import SwiftUI

@MainActor
struct CollectionFactory {

    // MARK: - Init

    init(deps: CollectionFactoryDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func makeScreen(with slug: String) -> UIViewController {
        let interactor = CollectionInteractor(
            deps: deps,
            slug: slug
        )
        let router = CollectionRouterImpl(deps: deps)
        let viewStateBuilder = CollectionViewStateBuilder()
        let wishlistProducer = CollectionWishlistActionPerformerProducer(deps: deps)
        let wishlistPerformer = wishlistProducer.makePerformer()
        let wishlistReporter = wishlistProducer.reporter
        let viewModel = CollectionViewModelImpl(
            interactor: interactor,
            router: router,
            viewStateBuilder: viewStateBuilder,
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        let rootView = CollectionView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        vc.hidesBottomBarWhenPushed = true
        return vc
    }

    // MARK: - Private Properties

    private let deps: CollectionFactoryDeps

}
