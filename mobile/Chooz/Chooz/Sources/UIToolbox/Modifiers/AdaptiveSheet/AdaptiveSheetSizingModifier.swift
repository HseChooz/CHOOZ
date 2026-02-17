import SwiftUI

// MARK: - AdaptiveSheetSizingModifier

struct AdaptiveSheetSizingModifier: ViewModifier {

    // MARK: - Protocol ViewModifier

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .readSize { size in
                contentHeight = size.height
            }
            .modifier(AdaptiveDetentsModifier(contentHeight: contentHeight))
            .presentationDragIndicator(
                Layout.dragIndicatorVisibility.value(for: interfaceLayout)
            )
    }

    // MARK: - Private Types

    private enum Layout {
        static let dragIndicatorVisibility = InterfaceLayoutValue<Visibility>(
            large: .hidden,
            compact: .visible
        )
    }

    // MARK: - Private Properties

    @Environment(\.interfaceLayout) private var interfaceLayout
    @State private var contentHeight: CGFloat = 0
}

// MARK: - AdaptiveDetentsModifier

private struct AdaptiveDetentsModifier: ViewModifier {

    let contentHeight: CGFloat

    // MARK: - Protocol ViewModifier

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            switch interfaceLayout {
            case .large:
                content
                    .presentationSizing(.fitted.sticky(horizontal: true, vertical: true))
                    .frame(width: 440.0)
            case .compact:
                content
                    .presentationDetents(
                        contentHeight > 0 ? [.height(contentHeight)] : [.medium]
                    )
            }
        } else {
            content
                .presentationDetents(
                    contentHeight > 0 ? [.height(contentHeight)] : [.medium]
                )
        }
    }

    // MARK: - Private Properties

    @Environment(\.interfaceLayout) private var interfaceLayout
}
