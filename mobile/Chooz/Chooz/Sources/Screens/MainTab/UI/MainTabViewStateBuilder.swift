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
                    )
                )
            ))
        }
        
        sections.append(.badgeSection(
            MainTabBadgeView.Model(
                title: "Что подарить второй половинке?",
                subtitle: "Подробнее",
                collectionSlug: "for-second-half"
            )
        ))

        sections.append(contentsOf: payload.sections.map { section in
            .defaultSection(
                MainTabDefaultSectionView.Model(
                    headerModel: MainTabDefaultSectionHeaderView.Model(
                        sectionId: section.key,
                        title: section.title
                    ),
                    collectionCards: section.collections.map { collection in
                        MainTabDefaultSectionCollectionCardView.Model(
                            slug: collection.slug,
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
