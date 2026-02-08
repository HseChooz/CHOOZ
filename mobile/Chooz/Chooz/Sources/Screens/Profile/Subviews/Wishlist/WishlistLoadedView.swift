import SwiftUI

struct WishlistLoadedView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel, items: [WishlistItem]) {
        self.viewModel = viewModel
        self.items = items
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16.0) {
            GeometryReader { geometry in
                let availableWidth = geometry.size.width - Static.padding * 2
                let columns = isCompact
                    ? Static.compactColumnsCount
                    : Self.columnsCount(for: availableWidth)
                
                ScrollView {
                    gridView(columns: columns)
                }
            }
            
            createWishButtonView
        }
        .padding(Static.padding)
        .sheet(isPresented: $viewModel.isAddWishSheetPresented) {
            AddWishView(viewModel: viewModel)
                .presentationDetents([.height(500.0)])
        }
    }
    
    // MARK: - Private Types
    
    private enum Static {
        static let compactColumnsCount: Int = 2
        static let iPadCardWidth: CGFloat = 160.0
        static let spacing: CGFloat = 20.0
        static let padding: CGFloat = 16.0
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let items: [WishlistItem]
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    // MARK: - Private Methods
    
    private static func columnsCount(for availableWidth: CGFloat) -> Int {
        max(1, Int((availableWidth + Static.spacing) / (Static.iPadCardWidth + Static.spacing)))
    }
    
    private func rowIndices(columns: Int) -> Range<Int> {
        let rowCount = (items.count + columns - 1) / columns
        return 0..<rowCount
    }
    
    private func itemsForRow(_ rowIndex: Int, columns: Int) -> [WishlistItem] {
        let start = rowIndex * columns
        let end = min(start + columns, items.count)
        return Array(items[start..<end])
    }
    
    // MARK: - Private Views
    
    private func gridView(columns: Int) -> some View {
        LazyVStack(spacing: Static.spacing) {
            ForEach(rowIndices(columns: columns), id: \.self) { rowIndex in
                let rowItems = itemsForRow(rowIndex, columns: columns)
                
                HStack(spacing: Static.spacing) {
                    ForEach(rowItems, id: \.id) { item in
                        if isCompact {
                            WishlistItemCardView(item: item)
                                .frame(maxWidth: .infinity)
                        } else {
                            WishlistItemCardView(item: item)
                                .frame(width: Static.iPadCardWidth)
                        }
                    }
                    
                    if rowItems.count < columns {
                        ForEach(0..<(columns - rowItems.count), id: \.self) { _ in
                            if isCompact {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                            } else {
                                Color.clear
                                    .frame(width: Static.iPadCardWidth)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var createWishButtonView: some View {
        Button(
            action: {
                viewModel.showAddWishSheet()
            },
            label: {
                Text("Создать желание")
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Common.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
        .background(Colors.Neutral.grey800)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
}
