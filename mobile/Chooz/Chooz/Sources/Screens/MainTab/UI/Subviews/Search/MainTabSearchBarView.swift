import SwiftUI

struct MainTabSearchBarView: View {
    
    // MARK: - Init
    
    init(searchText: Binding<String>) {
        self._searchText = searchText
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 8.0) {
            Images.Icons.search
                .resizable()
                .scaledToFill()
                .frame(width: 16.0, height: 16.0)
            
            TextField(
                "",
                text: $searchText,
                prompt: Text("Поиск")
                    .foregroundStyle(Colors.Neutral.grey700)
            )
                .font(.velaSans(size: 14.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey700)
                .lineLimit(1)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.leading, 10.0)
        .padding(.trailing, 10.0)
        .frame(height: 36.0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.Neutral.grey100)
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
    }
    
    // MARK: - Private Properties
    
    @Binding private var searchText: String
    
}

#Preview {
    MainTabSearchBarView(searchText: .constant(""))
}
