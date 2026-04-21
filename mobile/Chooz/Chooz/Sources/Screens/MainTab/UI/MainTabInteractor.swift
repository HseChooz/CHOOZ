import Foundation

@MainActor
protocol MainTabInteractorDeps {
    var mainTabService: MainTabService { get }
}

@MainActor
final class MainTabInteractor {

    // MARK: - Init

    init(deps: MainTabInteractorDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func requestSections() async throws -> MainTabSectionsPayload {
        async let upcomingEventResult: Result<EventItem?, Error> = requestResult(
            deps.mainTabService.fetchUpcomingEvent
        )
        async let sectionsResult: Result<[MainTabSectionsPayload.Section], Error> = requestResult(
            deps.mainTabService.fetchCollectionsHome
        )

        let (upcomingEventResultValue, sectionsResultValue) = await (upcomingEventResult, sectionsResult)

        switch (upcomingEventResultValue, sectionsResultValue) {
        case let (.success(upcomingEvent), .success(sections)):
            return MainTabSectionsPayload(
                upcomingEvent: upcomingEvent,
                sections: sections
            )
        case let (.success(upcomingEvent), .failure):
            return MainTabSectionsPayload(
                upcomingEvent: upcomingEvent,
                sections: []
            )
        case let (.failure, .success(sections)):
            return MainTabSectionsPayload(
                upcomingEvent: nil,
                sections: sections
            )
        case (.failure, .failure):
            throw MainTabErrorType.unknown
        }
    }

    // MARK: - Private Properties

    private let deps: MainTabInteractorDeps
    
    // MARK: - Private Methods

    private func requestResult<T>(
        _ operation: @escaping () async throws -> T
    ) async -> Result<T, Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }

}
