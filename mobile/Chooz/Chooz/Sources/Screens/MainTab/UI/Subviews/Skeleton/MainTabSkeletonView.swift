import SwiftUI

struct MainTabSkeletonView: View {
    
    // MARK: - Body
    
    var body: some View {
        let mask = skeletonView
        
        mask
            .foregroundStyle(Colors.Neutral.grey200)
            .shimmering(mask: mask)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 18.0)
    }
    
    // MARK: - Private Views
    
    private var skeletonView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30.0) {
                ForEach(0..<5, id: \.self) { _ in
                    sectionSkeletonView
                }
            }
        }
        .scrollDisabled(true)
    }
    
    private var sectionSkeletonView: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            sectionHeaderSkeletonView
                .padding(.horizontal, 18.0)
            
            ScrollView(.horizontal) {
                HStack(spacing: 18.0) {
                    ForEach(0..<10, id: \.self) { _ in
                        collectionCardSkeletonView
                    }
                }
                .padding(.horizontal, 18.0)
            }
            .scrollDisabled(true)
        }
    }
    
    private var sectionHeaderSkeletonView: some View {
        Rectangle()
            .frame(width: 170.0, height: 30.0)
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
        .frame(width: 139.9, height: 186.0)
    }
    
}
