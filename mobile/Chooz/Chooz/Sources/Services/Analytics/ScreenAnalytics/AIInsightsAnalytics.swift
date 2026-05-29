import Foundation

final class AIInsightsAnalytics {

    // MARK: - Init

    init(analyticsService: AnalyticsService, source: String) {
        self.analyticsService = analyticsService
        self.source = source
    }

    // MARK: - Internal Methods

    func trackOpened() {
        analyticsService.track(.aiInsightsOpened(source: source))
    }

    func trackGenerated() {
        analyticsService.track(.aiInsightsGenerated)
    }

    func trackRegenerated() {
        analyticsService.track(.aiInsightsRegenerated)
    }

    func trackError() {
        analyticsService.track(.aiInsightsError)
    }

    // MARK: - Private Properties

    private let analyticsService: AnalyticsService
    private let source: String
}
