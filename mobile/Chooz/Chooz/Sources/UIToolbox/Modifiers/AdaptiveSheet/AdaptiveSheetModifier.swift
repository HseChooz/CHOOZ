import SwiftUI

// MARK: - View Extension

extension View {

    /// Presents a system sheet whose height adapts to the content's intrinsic size.
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
