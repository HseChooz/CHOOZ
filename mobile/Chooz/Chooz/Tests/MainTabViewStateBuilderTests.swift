import Foundation
import Testing
@testable import Chooz

struct MainTabViewStateBuilderTests {
    
    @Test
    @MainActor
    func buildLoadedContentViewState_placesUpcomingSectionFirst() {
        let payload = MainTabSectionsPayload(
            upcomingEvent: makeEventItem(title: "День рождения"),
            sections: [makeSection(id: "collection-1", slug: "collection-slug")]
        )
        
        let result = MainTabViewStateBuilder().buildLoadedContentViewState(from: payload)
        
        #expect(result.sections.count == 2)
        
        switch result.sections[0] {
        case .upcomingEventSection(let model):
            #expect(model.eventModel.title == "День рождения")
            #expect(model.badgeModel == nil)
        case .defaultSection:
            #expect(Bool(false))
        }
        
        switch result.sections[1] {
        case .upcomingEventSection:
            #expect(Bool(false))
        case .defaultSection(let model):
            #expect(model.headerModel.sectionId == "editorial")
            #expect(model.collectionCards.first?.slug == "collection-1")
        }
    }
    
    @Test
    @MainActor
    func buildLoadedContentViewState_skipsUpcomingSectionWhenEventIsMissing() {
        let payload = MainTabSectionsPayload(
            upcomingEvent: nil,
            sections: [makeSection(id: "collection-1", slug: "collection-slug")]
        )
        
        let result = MainTabViewStateBuilder().buildLoadedContentViewState(from: payload)
        
        #expect(result.sections.count == 1)
        
        switch result.sections[0] {
        case .upcomingEventSection:
            #expect(Bool(false))
        case .defaultSection(let model):
            #expect(model.collectionCards.first?.slug == "collection-1")
        }
    }
    
    // MARK: - Private Methods
    
    private func makeEventItem(title: String) -> EventItem {
        EventItem(
            id: "event-1",
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
                    badge: nil,
                    coverImageUrl: URL(string: "https://example.com/image.png"),
                    itemsCount: 10
                )
            ]
        )
    }
}
