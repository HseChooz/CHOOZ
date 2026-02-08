import SwiftUI

struct WishlistSkeletonView: View {
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let columns = Self.columnsCount(for: geometry.size.width)
            let cardWidth = Self.cardWidth(
                for: geometry.size.width,
                columns: columns
            )
            let rows = Self.rowsCount(
                for: geometry.size.height,
                columns: columns
            )
            
            let mask = gridMask(
                rows: rows,
                columns: columns,
                cardWidth: cardWidth
            )
            
            mask
                .padding(16.0)
                .foregroundStyle(Colors.Neutral.grey200)
                .shimmering(mask: mask)
        }
    }
    
    // MARK: - Private Types
    
    private enum Static {
        static let referenceCardWidth: CGFloat = 160.0
        static let imageHeight: CGFloat = 193.0
        static let cornerRadius: CGFloat = 20.0
        static let spacing: CGFloat = 20.0
        static let textSpacing: CGFloat = 12.0
        static let titleHeight: CGFloat = 15.0
        static let subtitleSpacing: CGFloat = 4.0
        static let subtitleHeight: CGFloat = 10.0
        static let cardTotalHeight: CGFloat = imageHeight + textSpacing + titleHeight + subtitleSpacing + subtitleHeight
    }
    
    // MARK: - Private Views
    
    private func gridMask(
        rows: Int,
        columns: Int,
        cardWidth: CGFloat
    ) -> some View {
        VStack(spacing: Static.spacing) {
            ForEach(0..<rows, id: \.self) { _ in
                HStack(spacing: Static.spacing) {
                    ForEach(0..<columns, id: \.self) { _ in
                        cardSkeletonView(cardWidth: cardWidth)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private func cardSkeletonView(cardWidth: CGFloat) -> some View {
        VStack(spacing: Static.textSpacing) {
            RoundedRectangle(cornerRadius: Static.cornerRadius)
                .frame(width: cardWidth, height: Static.imageHeight)
            
            VStack(alignment: .leading, spacing: Static.subtitleSpacing) {
                Rectangle()
                    .frame(width: cardWidth, height: Static.titleHeight)
                
                Rectangle()
                    .frame(width: cardWidth / 3.0, height: Static.subtitleHeight)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private static func columnsCount(for availableWidth: CGFloat) -> Int {
        max(1, Int((availableWidth + Static.spacing) / (Static.referenceCardWidth + Static.spacing)))
    }
    
    private static func cardWidth(for availableWidth: CGFloat, columns: Int) -> CGFloat {
        let totalSpacing = Static.spacing * CGFloat(columns - 1)
        return (availableWidth - totalSpacing) / CGFloat(columns)
    }
    
    private static func rowsCount(for availableHeight: CGFloat, columns: Int) -> Int {
        max(1, Int((availableHeight + Static.spacing) / (Static.cardTotalHeight + Static.spacing)))
    }
}
