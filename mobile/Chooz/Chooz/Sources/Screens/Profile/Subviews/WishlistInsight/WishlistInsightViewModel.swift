import Foundation
import Observation

@MainActor
@Observable
final class WishlistInsightViewModel {

    // MARK: - Init

    init(insightService: WishlistInsightService, items: [WishlistItem]) {
        self.insightService = insightService
        self.items = items
    }

    // MARK: - Internal Properties

    var state: WishlistInsightService.State {
        insightService.state
    }

    var displayText: String {
        switch state {
        case .streaming(let text):
            return text
        case .generated(let text):
            return text
        case .error(let message):
            return message
        case .idle, .loading:
            return ""
        }
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    var isStreaming: Bool {
        if case .streaming = state { return true }
        return false
    }

    var isError: Bool {
        if case .error = state { return true }
        return false
    }

    var hasResult: Bool {
        if case .generated = state { return true }
        if case .streaming = state { return true }
        return false
    }

    // MARK: - Internal Methods

    func generate() async {
        await insightService.generateInsight(for: items)
    }

    func retry() async {
        insightService.reset()
        await generate()
    }

    // MARK: - Private Properties

    private let insightService: WishlistInsightService
    private let items: [WishlistItem]
}
