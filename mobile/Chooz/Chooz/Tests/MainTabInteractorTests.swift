import Foundation
import Testing
@testable import Chooz

struct MainTabInteractorTests {
    
    @Test
    @MainActor
    func requestSections_returnsCombinedPayloadWhenBothRequestsSucceed() async throws {
        let upcomingEvent = makeEventItem(id: "event-1", title: "День рождения")
        let sections = [makeSection(id: "collection-1", slug: "collection-slug")]
        let interactor = MainTabInteractor(
            deps: StubMainTabInteractorDeps(
                mainTabService: StubMainTabService(
                    upcomingEventResult: .success(upcomingEvent),
                    sectionsResult: .success(sections)
                )
            )
        )
        
        let payload = try await interactor.requestSections()
        
        #expect(payload.upcomingEvent == upcomingEvent)
        #expect(payload.sections == sections)
    }
    
    @Test
    @MainActor
    func requestSections_returnsCollectionsWhenUpcomingRequestFails() async throws {
        let sections = [makeSection(id: "collection-1", slug: "collection-slug")]
        let interactor = MainTabInteractor(
            deps: StubMainTabInteractorDeps(
                mainTabService: StubMainTabService(
                    upcomingEventResult: .failure(StubError.failed),
                    sectionsResult: .success(sections)
                )
            )
        )
        
        let payload = try await interactor.requestSections()
        
        #expect(payload.upcomingEvent == nil)
        #expect(payload.sections == sections)
    }
    
    @Test
    @MainActor
    func requestSections_returnsUpcomingEventWhenCollectionsRequestFails() async throws {
        let upcomingEvent = makeEventItem(id: "event-1", title: "День рождения")
        let interactor = MainTabInteractor(
            deps: StubMainTabInteractorDeps(
                mainTabService: StubMainTabService(
                    upcomingEventResult: .success(upcomingEvent),
                    sectionsResult: .failure(StubError.failed)
                )
            )
        )
        
        let payload = try await interactor.requestSections()
        
        #expect(payload.upcomingEvent == upcomingEvent)
        #expect(payload.sections.isEmpty)
    }
    
    @Test
    @MainActor
    func requestSections_throwsUnknownWhenBothRequestsFail() async {
        let interactor = MainTabInteractor(
            deps: StubMainTabInteractorDeps(
                mainTabService: StubMainTabService(
                    upcomingEventResult: .failure(StubError.failed),
                    sectionsResult: .failure(StubError.failed)
                )
            )
        )
        
        do {
            _ = try await interactor.requestSections()
            #expect(Bool(false))
        } catch let error as MainTabErrorType {
            #expect(error == .unknown)
        } catch {
            #expect(Bool(false))
        }
    }
    
    // MARK: - Private Methods
    
    private func makeEventItem(id: String, title: String) -> EventItem {
        EventItem(
            id: id,
            title: title,
            description: nil,
            link: nil,
            notifyEnabled: false,
            repeatYearly: false,
            date: Date(timeIntervalSince1970: 0)
        )
    }
    
    private func makeSection(id: String, slug: String) -> MainTabSectionsPayload.Section {
        MainTabSectionsPayload.Section(
            key: "editorial",
            title: "Редакция",
            collections: [
                MainTabSectionsPayload.Collection(
                    id: id,
                    slug: slug,
                    title: "Подборка",
                    subtitle: "Короткое описание",
                    coverImageUrl: URL(string: "https://example.com/image.png"),
                    itemsCount: 10
                )
            ]
        )
    }
}

@MainActor
private struct StubMainTabInteractorDeps: MainTabInteractorDeps {
    let mainTabService: MainTabService
}

private struct StubMainTabService: MainTabService {
    let upcomingEventResult: Result<EventItem?, Error>
    let sectionsResult: Result<[MainTabSectionsPayload.Section], Error>
    
    func fetchUpcomingEvent() async throws -> EventItem? {
        try upcomingEventResult.get()
    }
    
    func fetchCollectionsHome() async throws -> [MainTabSectionsPayload.Section] {
        try sectionsResult.get()
    }
}

private enum StubError: Error {
    case failed
}
