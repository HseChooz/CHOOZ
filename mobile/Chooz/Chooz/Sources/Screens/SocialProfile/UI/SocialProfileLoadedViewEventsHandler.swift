import Foundation

@MainActor
protocol SocialProfileLoadedViewEventsHandler: AnyObject {
    func openWishlistItem(id: String)
    func refreshProfile()
    func openAIInsight()
}
