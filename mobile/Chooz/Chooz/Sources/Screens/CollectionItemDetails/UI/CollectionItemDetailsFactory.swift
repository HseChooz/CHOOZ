import Foundation
import UIKit
import SwiftUI

@MainActor
struct CollectionItemDetailsFactory {
    
    // MARK: - Init
    
    init(deps: CollectionItemDetailsFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen(
        with collectionSlug: String,
        itemId: String,
        wishlistPerformer: any CollectionWishlistActionPerformer,
        wishlistReporter: any CollectionWishlistActionReporter
    ) -> UIViewController {
        let interactor = CollectionItemDetailsInteractor(
            deps: deps,
            collectionSlug: collectionSlug,
            itemId: itemId
        )
        let viewStateBuilder = CollectionItemDetailsViewStateBuilder()
        let viewModel = CollectionItemDetailsViewModelImpl(
            interactor: interactor,
            viewStateBuilder: viewStateBuilder,
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        let rootView = CollectionItemDetailsView(viewModel: viewModel)
        return UIHostingController(rootView: rootView)
    }
    
    // MARK: - Private Properties
    
    private let deps: CollectionItemDetailsFactoryDeps
    
}
