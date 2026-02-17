import SwiftUI

// MARK: - AdaptiveSheetModifier

struct AdaptiveSheetModifier<SheetContent: View>: ViewModifier {

    // MARK: - Init

    init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.sheetContent = sheetContent
    }

    // MARK: - Protocol ViewModifier

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                sheetContent()
                    .modifier(AdaptiveSheetSizingModifier())
            }
    }

    // MARK: - Private Properties

    @Binding private var isPresented: Bool
    private let onDismiss: (() -> Void)?
    private let sheetContent: () -> SheetContent
}

// MARK: - AdaptiveSheetItemModifier

struct AdaptiveSheetItemModifier<Item: Identifiable, SheetContent: View>: ViewModifier {

    // MARK: - Init

    init(
        item: Binding<Item?>,
        onDismiss: (() -> Void)?,
        @ViewBuilder sheetContent: @escaping (Item) -> SheetContent
    ) {
        self._item = item
        self.onDismiss = onDismiss
        self.sheetContent = sheetContent
    }

    // MARK: - Protocol ViewModifier

    func body(content: Content) -> some View {
        content
            .sheet(item: $item, onDismiss: onDismiss) { item in
                sheetContent(item)
                    .modifier(AdaptiveSheetSizingModifier())
            }
    }

    // MARK: - Private Properties

    @Binding private var item: Item?
    private let onDismiss: (() -> Void)?
    private let sheetContent: (Item) -> SheetContent
}
