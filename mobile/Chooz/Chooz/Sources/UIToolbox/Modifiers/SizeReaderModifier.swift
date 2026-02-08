import SwiftUI

// MARK: - View Extension

extension View {
    
    func readSize(into size: Binding<CGSize>) -> some View {
        modifier(SizeReaderModifier(size: size))
    }
    
    func readSize(onChange: @escaping ((CGSize) -> Void)) -> some View {
        readSize(into: Binding(get: { .zero }, set: onChange))
    }
}

// MARK: - SizeReaderModifier

private struct SizeReaderModifier: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .onGeometryChange(
                for: CGSize.self,
                of: { proxy in
                    proxy.size
                },
                action: { size in
                    self.size = size
                }
            )
    }
}
