import SwiftUI
import Observation

@MainActor
protocol MainTabViewModel:
    AnyObject,
    MainTabToolbarContentEventsHandler,
    MainTabLoadedViewEventsHandler
{
    var viewState: MainTabViewState { get }
    
    func requestSections()
    func retrySectionsRequest()
}

@MainActor
@Observable
final class MainTabViewModelImpl: MainTabViewModel {
    
    // MARK: - Internal Properties
    
    private(set) var viewState: MainTabViewState = .loading
    
    // MARK: - Init
    
    init(
        router: MainTabRouter,
        interactor: MainTabInteractor,
        viewStateBuilder: MainTabViewStateBuilder
    ) {
        self.router = router
        self.interactor = interactor
        self.viewStateBuilder = viewStateBuilder
    }
    
    // MARK: - Internal Methods
    
    func requestSections() {
        guard !hasRequestedSections else {
            return
        }
        
        hasRequestedSections = true
        forceRequestSections()
    }
    
    // MARK: - MainTabToolbarContentEventsHandler
    
    func openProfile() {
        router.routeTo(destination: .profile)
    }
    
    // MARK: - MainTabLoadedViewEventsHandler
    
    func refreshSections() {
        viewState = .loading
        forceRequestSections()
    }
    
    func openCollection(with id: String) {
    }
        
    func openCollectionsList(with sectionId: String) {
        router.routeTo(destination: .collectionsList(id: sectionId))
    }
    
    func openUpcomingEvents() {
        router.routeTo(destination: .calendar)
    }
    
    // MARK: - MainTabErrorViewEventsHandler
    
    func retrySectionsRequest() {
        viewState = .loading
        forceRequestSections()
    }
    
    // MARK: - Private Properties
    
    private let router: MainTabRouter
    private let interactor: MainTabInteractor
    private let viewStateBuilder: MainTabViewStateBuilder
    
    private var hasRequestedSections = false
    private var requestSectionsTask: Task<Void, Never>? = nil
    
    // MARK: - Private Methods
    
    private func forceRequestSections() {
        requestSectionsTask?.cancel()
        
        requestSectionsTask = Task {
            do {
                let payload = try await interactor.requestSections()
                viewState = .loaded(viewStateBuilder.buildLoadedContentViewState(from: payload))
            } catch let error as MainTabErrorType {
                print(error.localizedDescription)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: error))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildErrorViewState(from: .unknown))
            }
        }
    }

}
