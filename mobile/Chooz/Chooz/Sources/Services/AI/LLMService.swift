import Foundation
import FoundationModels

@MainActor
final class LLMService {

    // MARK: - Internal Types

    enum LLMError: LocalizedError {
        case deviceNotEligible
        case appleIntelligenceNotEnabled
        case modelNotReady
        case unsupportedLanguage
        case generationFailed(Error)

        var errorDescription: String? {
            switch self {
            case .deviceNotEligible:
                "Это устройство не поддерживает Apple Intelligence"
            case .appleIntelligenceNotEnabled:
                "Включите Apple Intelligence в Настройках → Apple Intelligence и Siri"
            case .modelNotReady:
                "Модели Apple Intelligence ещё не загружены. Подключитесь к Wi-Fi, поставьте устройство на зарядку и дождитесь завершения загрузки в Настройках → Apple Intelligence и Siri"
            case .unsupportedLanguage:
                "Apple Intelligence пока не поддерживает русский язык. Установите язык Siri на английский в Настройках → Apple Intelligence и Siri → Язык"
            case .generationFailed(let error):
                "Ошибка генерации: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Internal Properties

    private(set) var isModelLoaded: Bool = false

    // MARK: - Internal Methods

    func loadModelIfNeeded() async throws {
        guard !isModelLoaded else { return }

        let model = SystemLanguageModel.default

        switch model.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            throw LLMError.deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            throw LLMError.appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            throw LLMError.modelNotReady
        case .unavailable:
            throw LLMError.modelNotReady
        }

        guard model.supportsLocale(.current) else {
            throw LLMError.unsupportedLanguage
        }

        isModelLoaded = true
    }

    func generate(instructions: String, prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let session = LanguageModelSession(instructions: instructions)
                    let stream = session.streamResponse(to: prompt)

                    for try await partial in stream {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch let error as LanguageModelSession.GenerationError {
                    switch error {
                    case .unsupportedLanguageOrLocale:
                        continuation.finish(throwing: LLMError.unsupportedLanguage)
                    default:
                        let description = String(describing: error)
                        if description.contains("ModelCatalog") || description.contains("UnifiedAssetFramework") || description.contains("modelcatalog") {
                            continuation.finish(throwing: LLMError.modelNotReady)
                        } else {
                            continuation.finish(throwing: LLMError.generationFailed(error))
                        }
                    }
                } catch {
                    let description = String(describing: error)
                    if description.contains("ModelCatalog") || description.contains("UnifiedAssetFramework") || description.contains("modelcatalog") {
                        continuation.finish(throwing: LLMError.modelNotReady)
                    } else {
                        continuation.finish(throwing: LLMError.generationFailed(error))
                    }
                }
            }
        }
    }
}
