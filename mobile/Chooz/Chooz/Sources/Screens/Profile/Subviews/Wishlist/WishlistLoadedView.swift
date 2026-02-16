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
                let availableWidth = geometry.size.width - Layout.padding * 2
                let columns = columns(for: availableWidth)
                
                ScrollView {
                    gridView(columns: columns)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await viewModel.refreshWishes()
                }
            }
            
            createWishButtonView
        }
        .padding(Layout.padding)
        .sheet(isPresented: $viewModel.isWishFormSheetPresented) {
            WishFormView(viewModel: viewModel)
                .presentationDetents([.height(500.0)])
        }
        .adaptiveSheet(
            isPresented: $viewModel.isWishSheetPresented,
            onDismiss: { viewModel.handleWishSheetDismiss() }
        ) {
            WishView(viewModel: viewModel)
        }
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let compactColumnsCount: Int = 2
        static let iPadCardWidth: CGFloat = 160.0
        static let spacing: CGFloat = 20.0
        static let padding: CGFloat = 16.0
        static let cardMaxWidth: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: 160.0,
            compact: .infinity
        )
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
    @Environment(\.interfaceLayout) private var interfaceLayout
    
    private let items: [WishlistItem]
    
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
        LazyVStack(spacing: Layout.spacing) {
            ForEach(rowIndices(columns: columns), id: \.self) { rowIndex in
                let rowItems = itemsForRow(rowIndex, columns: columns)
                
                HStack(spacing: Layout.spacing) {
                    ForEach(rowItems, id: \.id) { item in
                        WishlistItemCardView(item: item) {
                            viewModel.selectWishItem(item)
                        }
                        .frame(maxWidth: Layout.cardMaxWidth.value(for: interfaceLayout))
                    }
                    
                    if rowItems.count < columns {
                        ForEach(0..<(columns - rowItems.count), id: \.self) { _ in
                            Color.clear
                                .frame(maxWidth: Layout.cardMaxWidth.value(for: interfaceLayout))
                        }
                    }
                }
            }
        }
    }
    
    private var createWishButtonView: some View {
        Button(
            action: {
                viewModel.showCreateWishForm()
            },
            label: {
                Text("Создать желание")
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Common.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50.0)
                    .background(Colors.Neutral.grey800)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
}
