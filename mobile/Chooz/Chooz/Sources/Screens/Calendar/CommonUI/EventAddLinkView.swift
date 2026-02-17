import SwiftUI

struct EventAddLinkView: View {
    
    // MARK: - Init
    
    init(linkString: Binding<String>) {
        self._linkString = linkString
    }
    
    // MARK: - Body
    
    var body: some View {
        TextField(
            "",
            text: $linkString,
            prompt: Text("Добавить ссылку")
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey400)
        )
        .font(.velaSans(size: 16.0, weight: .bold))
        .foregroundStyle(Colors.Neutral.grey800)
        .keyboardType(.URL)
        .textContentType(.URL)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .multilineTextAlignment(.center)
        .frame(height: 64.0)
        .overlay {
            RoundedRectangle(cornerRadius: 20.0)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.0, dash: [6.0]))
                .foregroundStyle(Colors.Neutral.grey400)
        }
    }
    
    // MARK: - Private Properties
    
    @Binding private var linkString: String
}
