import Foundation

@MainActor
protocol SocialProfileLoadedViewEventsHandler: AnyObject {
    func openWishlistItem(id: String)
    func refreshProfile()
    var isAIInsightsPresented: Bool { get set }
    func makeAIInsightsViewModel() -> AIInsightsViewModel
}
