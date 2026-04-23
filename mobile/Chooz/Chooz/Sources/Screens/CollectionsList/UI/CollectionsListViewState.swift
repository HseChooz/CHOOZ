import Foundation

enum CollectionsListViewState {
    
    case loading
    case loaded(CollectionsListLoadedView.Model)
    case error(ScreenErrorView.Model)
    
}
