import SwiftUI

// MARK: - View Extension

extension View {

    /// Presents a system sheet whose height adapts to the content's intrinsic size.
    ///
    /// The modifier forces the content to report its ideal vertical size,
    /// measures the resulting height, and applies it as a `presentationDetent`.
    ///
    /// ### Example:
    /// ```swift
    /// .adaptiveSheet(isPresented: $showSheet) {
    ///     VStack(spacing: 16) {
    ///         Text("Title")
    ///         Button("Done") { showSheet = false }
    ///     }
    ///     .padding()
    /// }
    /// ```
    func adaptiveSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(
            AdaptiveSheetModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                sheetContent: content
            )
        )
    }

    /// Presents a system sheet whose height adapts to the content's intrinsic size,
    /// driven by an optional `Identifiable` item.
    ///
    /// ### Example:
    /// ```swift
    /// .adaptiveSheet(item: $selectedItem) { item in
    ///     ItemDetailView(item: item)
    /// }
    /// ```
    func adaptiveSheet<Item: Identifiable, SheetContent: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> SheetContent
    ) -> some View {
        modifier(
            AdaptiveSheetItemModifier(
                item: item,
                onDismiss: onDismiss,
                sheetContent: content
            )
        )
    }
}

// MARK: - AdaptiveSheetModifier

private struct AdaptiveSheetModifier<SheetContent: View>: ViewModifier {

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
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .readSize { size in
                        contentHeight = size.height
                    }
                    .presentationDetents(
                        contentHeight > 0 ? [.height(contentHeight)] : [.medium]
                    )
                    .presentationDragIndicator(.visible)
            }
    }

    // MARK: - Private Properties

    @Binding private var isPresented: Bool
    private let onDismiss: (() -> Void)?
    private let sheetContent: () -> SheetContent
    @State private var contentHeight: CGFloat = 0
}

// MARK: - AdaptiveSheetItemModifier

private struct AdaptiveSheetItemModifier<Item: Identifiable, SheetContent: View>: ViewModifier {

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
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .readSize { size in
                        contentHeight = size.height
                    }
                    .presentationDetents(
                        contentHeight > 0 ? [.height(contentHeight)] : [.medium]
                    )
                    .presentationDragIndicator(.visible)
            }
    }

    // MARK: - Private Properties

    @Binding private var item: Item?
    private let onDismiss: (() -> Void)?
    private let sheetContent: (Item) -> SheetContent
    @State private var contentHeight: CGFloat = 0
}
