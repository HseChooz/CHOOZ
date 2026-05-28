import Foundation
import CoreMLLLM
import Observation

@MainActor
@Observable
final class WishlistInsightService {

    // MARK: - Internal Types

    enum State: Equatable {
        case idle
        case loading
        case streaming(String)
        case generated(String)
        case error(String)
    }

    // MARK: - Init

    init(cacheService: InsightCacheService) {
        self.cacheService = cacheService
    }

    // MARK: - Internal Properties

    private(set) var state: State = .idle

    // MARK: - Internal Methods

    func generateInsight(for items: [WishlistItem]) async {
        guard !items.isEmpty else {
            state = .error("Вишлист пуст — добавьте желания, чтобы ИИ мог проанализировать интересы.")
            return
        }

        if let cached = cacheService.cachedInsight(for: items) {
            state = .generated(cached)
            return
        }

        state = .loading

        do {
            let llm = try await loadModel()
            let prompt = promptBuilder.buildPrompt(items: items)

            var result = ""
            state = .streaming("")

            for try await token in llm.stream(prompt) {
                if token.contains("<|im_end|>") { break }
                result += token
                state = .streaming(result)
            }

            let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
            cacheService.saveInsight(trimmed, for: items)
            state = .generated(trimmed)
        } catch {
            state = .error("Не удалось сгенерировать описание: \(error.localizedDescription)")
        }
    }

    func reset() {
        state = .idle
    }

    // MARK: - Private Properties

    private let cacheService: InsightCacheService
    private let promptBuilder = InsightPromptBuilder()
    private var loadedModel: CoreMLLLM?

    // MARK: - Private Methods

    private func loadModel() async throws -> CoreMLLLM {
        if let model = loadedModel {
            return model
        }

        guard let modelPath = Bundle.main.path(forResource: "Qwen2.5-0.5B", ofType: nil) else {
            throw InsightError.modelNotFound
        }

        let modelURL = URL(fileURLWithPath: modelPath)
        let model = try await CoreMLLLM.load(from: modelURL)
        loadedModel = model
        return model
    }
}

// MARK: - InsightError

extension WishlistInsightService {

    enum InsightError: LocalizedError {
        case modelNotFound

        var errorDescription: String? {
            switch self {
            case .modelNotFound:
                return "ML-модель не найдена в бандле приложения."
            }
        }
    }
}
