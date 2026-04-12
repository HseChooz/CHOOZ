import SwiftUI

struct AddLinkView: View {
    
    // MARK: - Init
    
    init(linkString: Binding<String>) {
        self._linkString = linkString
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8.0) {
            TextField(
                "",
                text: $linkString,
                prompt: Text("Добавить ссылку")
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey500)
            )
            .font(.velaSans(size: 16.0, weight: .bold))
            .foregroundStyle(Colors.Neutral.grey800)
            .keyboardType(.URL)
            .textContentType(.URL)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .multilineTextAlignment(.leading)
            
            HorizontalLine()
                .stroke(lineWidth: 1.0)
                .foregroundStyle(Colors.Neutral.grey200)
                .frame(height: 1)
        }
    }
    
    // MARK: - Private Properties
    
    @Binding private var linkString: String
}
