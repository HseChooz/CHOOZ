import Foundation
import UIKit
import SwiftUI

@MainActor
struct CollectionsListFactory {
    
    // MARK: - Init
    
    init(deps: CollectionsListFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen(with sectionId: String) -> UIViewController {
        let interactor = CollectionsListInteractor(
            deps: deps,
            sectionId: sectionId
        )
        let router = CollectionsListRouter(deps: deps)
        let viewStateBuilder = CollectionsListViewStateBuilder()
        let viewModel = CollectionsListViewModelImpl(
            interactor: interactor,
            router: router,
            viewStateBuilder: viewStateBuilder
        )
        let rootView = CollectionsListView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    // MARK: - Private Properties
    
    private let deps: CollectionsListFactoryDeps
    
}
