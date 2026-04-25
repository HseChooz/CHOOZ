import Foundation

enum MainTabViewState {
    
    case loading
    case loaded(LoadedModel)
    case error(ScreenErrorView.Model)
    
    struct LoadedModel: Hashable {
        
        enum MainTabSectionType: Hashable {
            case upcomingEventSection(MainTabUpcomingEventsSectionView.Model)
            case defaultSection(MainTabDefaultSectionView.Model)
            case badgeSection(MainTabBadgeView.Model?)
        }
        
        let sections: [MainTabSectionType]
        
    }
    
}
