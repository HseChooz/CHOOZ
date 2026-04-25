import SwiftUI

struct CollectionSkeletonView: View {
    
    // MARK: - Body
    
    var body: some View {
        let mask = skeletonView
        
        mask
            .foregroundStyle(Colors.Neutral.grey200)
            .shimmering(mask: mask)
            .padding(.top, 14.0)
            .padding(.horizontal, 18.0)
    }
    
    // MARK: - Private Types
    
    private enum Static {
        
        static let columns = [
            GridItem(.adaptive(minimum: 160.0, maximum: 220.0), spacing: 6.0)
        ]
        
    }
    
    // MARK: - Private Views
    
    private var skeletonView: some View {
        VStack(alignment: .leading, spacing: 23.0) {
            headerSkeletonView
            
            ScrollView {
                LazyVGrid(columns: Static.columns, alignment: .leading, spacing: 22.0) {
                    ForEach(0..<10, id: \.self) { _ in
                        wishCardSkeletonView
                    }
                }
            }
            .scrollDisabled(true)
        }
    }
    
    private var headerSkeletonView: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            VStack(alignment: .leading, spacing: 3.0) {
                Rectangle()
                    .frame(width: 139.0, height: 33.0)
                
                Rectangle()
                    .frame(width: 264.0, height: 64.0)
            }
            
            HStack(spacing: 9.0) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10.0)
                        .frame(width: 126.0, height: 31.0)
                }
            }
        }
    }
    
    private var wishCardSkeletonView: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            RoundedRectangle(cornerRadius: 20.0)
            
            VStack(alignment: .leading, spacing: 2.0) {
                Rectangle()
                    .frame(width: 90.0, height: 20.0)
                
                Rectangle()
                    .frame(width: 70.0, height: 16.0)
            }
        }
        .frame(height: 253.0)
    }
    
}

#Preview {
    CollectionSkeletonView()
}
