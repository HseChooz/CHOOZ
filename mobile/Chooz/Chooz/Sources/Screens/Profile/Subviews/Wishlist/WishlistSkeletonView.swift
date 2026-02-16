import SwiftUI

struct WishlistSkeletonView: View {
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - Layout.padding * 2
            let columns = columns(for: availableWidth)
            let totalItems = Layout.totalItems.value(for: interfaceLayout)
            
            let mask = gridMask(columns: columns, totalItems: totalItems)
            
            mask
                .padding(Layout.padding)
                .foregroundStyle(Colors.Neutral.grey200)
                .shimmering(mask: mask)
        }
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let compactColumnsCount: Int = 2
        static let iPadCardWidth: CGFloat = 160.0
        static let imageHeight: CGFloat = 193.0
        static let cornerRadius: CGFloat = 20.0
        static let spacing: CGFloat = 20.0
        static let padding: CGFloat = 16.0
        static let textSpacing: CGFloat = 12.0
        static let titleHeight: CGFloat = 15.0
        static let subtitleSpacing: CGFloat = 4.0
        static let subtitleHeight: CGFloat = 10.0
        static let cardMaxWidth: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: 160.0,
            compact: .infinity
        )
        static let totalItems: InterfaceLayoutValue<Int> = InterfaceLayoutValue(
            large: 10,
            compact: 4
        )
    }
    
    // MARK: - Private Properties
    
    @Environment(\.interfaceLayout) private var interfaceLayout
    
    // MARK: - Private Methods
    
    private func columns(for availableWidth: CGFloat) -> Int {
        switch interfaceLayout {
        case .compact:
            return Layout.compactColumnsCount
        case .large:
            return Self.columnsCount(for: availableWidth)
        }
    }
    
    private static func columnsCount(for availableWidth: CGFloat) -> Int {
        max(1, Int((availableWidth + Layout.spacing) / (Layout.iPadCardWidth + Layout.spacing)))
    }
    
    // MARK: - Private Views
    
    private func gridMask(columns: Int, totalItems: Int) -> some View {
        let rowCount = (totalItems + columns - 1) / columns
        
        return VStack(spacing: Layout.spacing) {
            ForEach(0..<rowCount, id: \.self) { rowIndex in
                let startIndex = rowIndex * columns
                let itemsInRow = min(columns, totalItems - startIndex)
                
                HStack(spacing: Layout.spacing) {
                    ForEach(0..<itemsInRow, id: \.self) { _ in
                        cardSkeletonView
                            .frame(maxWidth: Layout.cardMaxWidth.value(for: interfaceLayout))
                    }
                    
                    if itemsInRow < columns {
                        ForEach(0..<(columns - itemsInRow), id: \.self) { _ in
                            Color.clear
                                .frame(maxWidth: Layout.cardMaxWidth.value(for: interfaceLayout))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var cardSkeletonView: some View {
        VStack(alignment: .leading, spacing: Layout.textSpacing) {
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .frame(maxWidth: .infinity)
                .frame(height: Layout.imageHeight)
            
            VStack(alignment: .leading, spacing: Layout.subtitleSpacing) {
                RoundedRectangle(cornerRadius: 4.0)
                    .frame(maxWidth: .infinity)
                    .frame(height: Layout.titleHeight)
                
                RoundedRectangle(cornerRadius: 4.0)
                    .frame(width: 50.0, height: Layout.subtitleHeight)
            }
        }
    }
}
