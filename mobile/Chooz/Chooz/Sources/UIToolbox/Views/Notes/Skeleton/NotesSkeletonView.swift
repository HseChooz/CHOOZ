import SwiftUI

struct NotesSkeletonView: View {
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { _ in
                let mask = noteSkeletonView

                mask
                    .foregroundStyle(Colors.Neutral.grey200)
                    .shimmering(mask: mask)
            }
        }
        .scrollDisabled(true)
        .padding(.top, 26.0)
        .padding(.horizontal, 17.0)
    }
    
    // MARK: - Private Views
    
    private var noteSkeletonView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Rectangle()
                .frame(width: 260.0, height: 16.0)
            
            Rectangle()
                .frame(width: 200.0, height: 14.0)
        }
        .padding(.leading, 16.0)
        .frame(height: 86.0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
        .overlay {
            RoundedRectangle(cornerRadius: 20.0)
                .stroke(Colors.Neutral.grey200)
        }
    }
    
}

#Preview {
    NotesSkeletonView()
}
