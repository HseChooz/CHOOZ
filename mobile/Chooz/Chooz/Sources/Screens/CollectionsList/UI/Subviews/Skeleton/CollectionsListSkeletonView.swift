import SwiftUI

struct CollectionsListSkeletonView: View {
    
    // MARK: - Body
    
    var body: some View {
        let mask = skeletonView
        
        mask
            .foregroundStyle(Colors.Neutral.grey200)
            .shimmering(mask: mask)
            .padding(.top, 28.0)
    }
    
    // MARK: - Private Types
    
    private enum Static {
        
        static let columns = [
            GridItem(.adaptive(minimum: 150.0, maximum: 150.0), spacing: 16.0)
        ]
        
    }
    
    // MARK: - Private Views
    
    private var skeletonView: some View {
        VStack(alignment: .leading, spacing: 28.0) {
            Rectangle()
                .frame(width: 213.0, height: 33.0)
            
            ScrollView {
                LazyVGrid(columns: Static.columns, alignment: .leading, spacing: 14.0) {
                    ForEach(0..<10, id: \.self) { _ in
                        collectionCardSkeletonView
                    }
                }
            }
            .scrollDisabled(true)
        }
        .padding(.horizontal, 19.0)
    }
    
    private var collectionCardSkeletonView: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            RoundedRectangle(cornerRadius: 20.0)
            
            VStack(alignment: .leading, spacing: 2.0) {
                Rectangle()
                    .frame(width: 80.0, height: 20.0)
                
                Rectangle()
                    .frame(width: 60.0, height: 16.0)
            }
        }
        .frame(height: 203.0)
    }
    
}

#Preview {
    CollectionsListSkeletonView()
}
