import Foundation

@MainActor
struct MainTabViewStateBuilder {
    
    // MARK: - Internal Methods
    
    func buildLoadedContentViewState(
        from payload: MainTabSectionsPayload,
        searchText: String = ""
    ) -> MainTabViewState.LoadedModel {
        var sections: [MainTabViewState.LoadedModel.MainTabSectionType] = []
        let searchTerms = makeSearchTerms(from: searchText)
        let isSearchActive = !searchTerms.isEmpty
        
        if !isSearchActive, let upcomingEvent = payload.upcomingEvent {
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
        
        if !isSearchActive {
            sections.append(.badgeSection(
                MainTabBadgeView.Model(
                    title: "Что подарить второй половинке?",
                    subtitle: "Подробнее",
                    collectionSlug: "for-second-half"
                )
            ))
        }

        sections.append(contentsOf: payload.sections.compactMap { section in
            let collections = isSearchActive
                ? section.collections.filter { collection in
                    matchesSearchTerms(searchTerms, in: collection)
                }
                : section.collections
            
            guard !collections.isEmpty else {
                return nil
            }
            
            return .defaultSection(
                MainTabDefaultSectionView.Model(
                    headerModel: MainTabDefaultSectionHeaderView.Model(
                        sectionId: section.key,
                        title: section.title
                    ),
                    collectionCards: collections.map { collection in
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

        return MainTabViewState.LoadedModel(
            sections: sections,
            emptyStateTitle: isSearchActive && sections.isEmpty ? "Подборки не найдены" : nil
        )
    }
    
    func buildErrorViewState(from error: MainTabErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }
    
    // MARK: - Private Methods
    
    private func makeSearchTerms(from searchText: String) -> [String] {
        searchText
            .split(whereSeparator: \.isWhitespace)
            .map { normalizeSearchValue(String($0)) }
            .filter { !$0.isEmpty }
    }
    
    private func matchesSearchTerms(
        _ searchTerms: [String],
        in collection: MainTabSectionsPayload.Collection
    ) -> Bool {
        guard !searchTerms.isEmpty else {
            return true
        }
        
        let searchValues = [
            collection.title,
            collection.subtitle,
            collection.badge
        ].compactMap { $0 }
        
        let haystack = normalizeSearchValue(searchValues.joined(separator: " "))
        return searchTerms.allSatisfy { haystack.contains($0) }
    }
    
    private func normalizeSearchValue(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
        
}
