import Foundation
import Observation

@MainActor
@Observable
final class AIInsightsViewModel {

    // MARK: - Init

    init(
        llmService: LLMService,
        items: [WishlistItem],
        userName: String?,
        analytics: AIInsightsAnalytics
    ) {
        self.llmService = llmService
        self.items = items
        self.userName = userName
        self.analytics = analytics

        if items.isEmpty {
            state = .emptyWishlist
        }
    }

    // MARK: - Internal Properties

    private(set) var state: AIInsightsState = .loading
    private(set) var generatedText: String = ""

    // MARK: - Internal Methods

    func generateInsights() {
        guard state != .emptyWishlist else { return }
        guard state != .generating else { return }

        generationTask?.cancel()
        generatedText = ""
        state = .loading

        analytics.trackOpened()

        generationTask = Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await llmService.loadModelIfNeeded()
            } catch let llmError as LLMService.LLMError {
                if case .unsupportedLanguage = llmError {
                    state = .languageNotSupported
                } else {
                    state = .error(llmError.localizedDescription ?? "Apple Intelligence недоступен")
                }
                analytics.trackError()
                return
            } catch {
                state = .error(error.localizedDescription)
                analytics.trackError()
                return
            }

            guard !Task.isCancelled else { return }

            state = .generating

            let stream = llmService.generate(
                instructions: Self.systemInstructions,
                prompt: buildPrompt()
            )

            do {
                for try await text in stream {
                    guard !Task.isCancelled else { return }
                    generatedText = text
                }
            } catch let llmError as LLMService.LLMError {
                if case .unsupportedLanguage = llmError {
                    state = .languageNotSupported
                } else {
                    state = .error(llmError.localizedDescription ?? "Ошибка генерации")
                }
                analytics.trackError()
                return
            } catch {
                state = .error(error.localizedDescription)
                analytics.trackError()
                return
            }

            guard !Task.isCancelled else { return }

            state = .completed
            analytics.trackGenerated()
        }
    }

    func regenerate() {
        analytics.trackRegenerated()
        state = .loading
        generationTask?.cancel()
        generationTask = nil
        generatedText = ""

        generateInsights()
    }

    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
    }

    // MARK: - Private Properties

    private let llmService: LLMService
    private let items: [WishlistItem]
    private let userName: String?
    private let analytics: AIInsightsAnalytics
    private var generationTask: Task<Void, Never>?

    // MARK: - Private Methods

    private func buildPrompt() -> String {
        let itemsList = items
            .prefix(20)
            .map { $0.title }
            .joined(separator: ", ")

        let name = userName ?? "this person"

        return "Here is the wishlist of \(name): \(itemsList). Describe this person based on their wishlist."
    }

    private static let systemInstructions = """
    You are an expert who creates a personality profile based on a person's wishlist. \
    Analyze all items together and describe the owner: character, lifestyle, hobbies, values and tastes. \
    Do NOT list or describe individual items — generalize and draw conclusions about the person. \
    At the end, suggest 2-3 gift ideas that are NOT in the wishlist but would suit this person. \
    Be concise (5-7 sentences).
    """
}
