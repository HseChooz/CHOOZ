import SwiftUI

struct CollectionItemDetailsSkeletonView: View {
    
    var body: some View {
        let mask = skeletonView
        
        mask
            .foregroundStyle(Colors.Neutral.grey200)
            .shimmering(mask: mask)
    }
    
    var skeletonView: some View {
        VStack(alignment: .leading, spacing: 24.0) {
            Colors.Neutral.grey200
                .frame(height: 387.0)
            
            VStack(alignment: .leading, spacing: 20.0) {
                Rectangle()
                    .frame(height: 33.0)
                
                Rectangle()
                    .frame(height: 80.0)
            }
            
            RoundedRectangle(cornerRadius: 14.0)
                .frame(height: 50.0)
        }
    }
}

#Preview {
    CollectionItemDetailsSkeletonView()
}
