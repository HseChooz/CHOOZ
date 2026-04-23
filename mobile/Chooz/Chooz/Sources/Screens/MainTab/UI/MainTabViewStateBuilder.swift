import Foundation

@MainActor
struct MainTabViewStateBuilder {
    
    // MARK: - Internal Methods
    
    func buildLoadedContentViewState(from payload: MainTabSectionsPayload) -> MainTabViewState.LoadedModel {
        var sections: [MainTabViewState.LoadedModel.MainTabSectionType] = []
        
        if let upcomingEvent = payload.upcomingEvent {
            sections.append(.upcomingEventSection(
                MainTabUpcomingEventsSectionView.Model(
                    headerModel: MainTabUpcomingEventsSectionHeaderView.Model(
                        title: "Ближайшие события"
                    ),
                    eventModel: CalendarEventRowView.Model(
                        title: upcomingEvent.title,
                        shortMonthString: upcomingEvent.shortMonthString,
                        dayString: upcomingEvent.dayString,
                        daysRemainingString: upcomingEvent.daysRemainingString
                    ),
                    badgeModel: MainTabBadgeView.Model(
                        title: "Что подарить второй половинке?",
                        subtitle: "Подробнее",
                        collectionId: "1"
                    )
                )
            ))
        }

        sections.append(contentsOf: payload.sections.map { section in
            .defaultSection(
                MainTabDefaultSectionView.Model(
                    headerModel: MainTabDefaultSectionHeaderView.Model(
                        sectionId: section.key,
                        title: section.title
                    ),
                    collectionCards: section.collections.map { collection in
                        MainTabDefaultSectionCollectionCardView.Model(
                            id: collection.id,
                            title: collection.title,
                            subtitle: collection.subtitle,
                            imageUrl: collection.coverImageUrl
                        )
                    }
                )
            )
        })

        return MainTabViewState.LoadedModel(sections: sections)
    }
    
    func buildErrorViewState(from error: MainTabErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }
        
}
