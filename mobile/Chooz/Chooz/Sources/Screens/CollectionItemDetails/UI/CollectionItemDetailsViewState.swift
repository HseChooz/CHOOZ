import Foundation

enum CollectionItemDetailsViewState {
    
    case loading
    case loaded(CollectionItemDetailsLoadedView.Model)
    case error(ScreenErrorView.Model)
    
}
