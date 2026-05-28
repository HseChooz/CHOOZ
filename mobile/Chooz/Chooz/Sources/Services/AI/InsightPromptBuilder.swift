import Foundation

struct InsightPromptBuilder {

    // MARK: - Internal Methods

    func buildPrompt(items: [WishlistItem]) -> String {
        let trimmedItems = Array(items.prefix(maxItems))

        let itemsList = trimmedItems.enumerated().map { idx, item in
            var entry = "\(idx + 1). \(item.title)"
            if let description = item.description, !description.isEmpty {
                entry += " — \(description)"
            }
            return entry
        }.joined(separator: "\n")

        return """
        <|im_start|>system
        Ты — помощник в подборе подарков. На основе вишлиста человека опиши его интересы, \
        увлечения и предпочтения в 2-4 предложениях. Пиши на русском языке, кратко и по делу. \
        Не повторяй список, а обобщай.
        <|im_end|>
        <|im_start|>user
        Вишлист:
        \(itemsList)

        Опиши интересы этого человека.
        <|im_end|>
        <|im_start|>assistant
        """
    }

    // MARK: - Private Properties

    private let maxItems = 20
}
