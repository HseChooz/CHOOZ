import Foundation

enum CollectionViewState {
    
    case loading
    case loaded(CollectionLoadedView.Model)
    case error(ScreenErrorView.Model)
    
}
