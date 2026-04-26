import Foundation
import UIKit
import SwiftUI

@MainActor
struct NotesTabFactory {
    
    // MARK: - Init
    
    init(deps: NotesTabFactoryDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = NotesTabRouter(deps: deps)
        let viewModel = NotesTabViewModelImpl(
            router: router,
            noteReporter: deps.noteActionPerformerProducer.reporter,
            toastManager: deps.toastManager
        )
        let notesView = deps.notesFactory.makeView()
        let favoriteNotesFactory = deps.favoriteNotesFactory.makeView()
        let rootView = NotesTabView(
            viewModel: viewModel,
            notesView: notesView,
            favoriteNotesView: favoriteNotesFactory
        )
        let hostingController = UIHostingController(rootView: rootView)
        let navigationController = UINavigationController(rootViewController: hostingController)
        
        configureNavigationBarAppearance(for: navigationController)
        
        return navigationController
    }
    
    // MARK: - Private Properties
    
    private let deps: NotesTabFactoryDeps
    
    // MARK: - Private Methods
    
    private func configureNavigationBarAppearance(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = nil
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
    }
    
}
