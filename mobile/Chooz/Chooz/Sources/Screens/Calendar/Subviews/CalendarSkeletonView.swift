import SwiftUI

struct CalendarSkeletonView: View {
    
    // MARK: - Body
    
    var body: some View {
        let mask = skeletonMask
        
        mask
            .shimmering(mask: mask)
    }
    
    // MARK: - Private Types
    
    private enum Static {
        static let rowsCount: InterfaceLayoutValue<Int> = InterfaceLayoutValue(
            large: 6,
            compact: 4
        )
    }
    
    // MARK: - Private Properties
    
    @Environment(\.interfaceLayout) private var interfaceLayout
    
    // MARK: - Private Views
    
    private var skeletonMask: some View {
        VStack(spacing: 8.0) {
            ForEach(0..<Static.rowsCount.value(for: interfaceLayout), id: \.self) { _ in
                skeletonRowView
            }
        }
        .padding(.top, 24.0)
        .padding(.horizontal, 16.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var skeletonRowView: some View {
        RoundedRectangle(cornerRadius: 20.0)
            .fill(Colors.Neutral.grey200)
            .frame(height: 80.0)
            .frame(maxWidth: .infinity)
    }
}
