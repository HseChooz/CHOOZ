import SwiftUI

// MARK: - View Extension

extension View {
    
    /// Applies shimmering using the specified mask.
    ///
    /// ### Usage:
    /// 1. Construct mask for the placeholder view.
    ///    The mask's opacity will be applied to the effect, so using views with `alpha == 1` is recommended.
    /// 2. Apply styling (such as `.foregroundStyle`) to the mask.
    /// 3. Apply the modifier to the styled view, pass the unstyled mask into the mask parameter.
    ///
    /// ### Example:
    /// ```swift
    /// mask                       // 1. Place mask
    ///    .foregroundStyle(...)   // 2. Apply styling
    ///    .shimmering(mask: mask) // 3. Apply shimmering
    /// ```
    func shimmering(mask: some View) -> some View {
        modifier(ShimmerModifier(mask: mask))
    }
}

// MARK: - ShimmerModifier

private struct ShimmerModifier<Mask: View>: ViewModifier {
    
    // MARK: - Init
    
    init(mask: Mask) {
        self.shimmerMask = mask
    }
    
    // MARK: - Protocol ViewModifier
    
    func body(content: Content) -> some View {
        content
            .readSize(into: $contentSize)
            .overlay {
                if contentSize.width != 0, contentSize.height != 0 {
                    shimmer
                        .allowsHitTesting(false)
                }
            }
    }
    
    // MARK: - Private Properties
    
    private let shimmerMask: Mask
    @State private var contentSize: CGSize = .zero
    @State private var isInitial: Bool = true
    
    private var shimmer: some View {
        LinearGradient(
            gradient: Static.gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .flipsForRightToLeftLayoutDirection(true)
        .mask(shimmerMask)
        .animation(Static.animation, value: isInitial)
        .onAppear {
            isInitial = false
        }
    }
    
    // MARK: - Math Helpers
    
    private var startPoint: UnitPoint {
        isInitial
            ? UnitPoint(x: -dAnchors.width, y: -dAnchors.height)
            : UnitPoint(x: 1, y: 1)
    }
    
    private var endPoint: UnitPoint {
        isInitial
            ? UnitPoint(x: 0, y: 0)
            : UnitPoint(x: 1 + dAnchors.width, y: 1 + dAnchors.height)
    }
    
    private var dAnchors: CGSize {
        let angle = CGFloat(Static.angle.radians)
        let heightScale = contentSize.width / contentSize.height
        return CGSize(
            width: cos(angle) * Static.shimmerToContentWidthRatio,
            height: sin(angle) * Static.shimmerToContentWidthRatio * heightScale
        )
    }
}

// MARK: - Static

private enum Static {
    static let shimmerToContentWidthRatio: CGFloat = 0.3
    static let angle: Angle = .degrees(30)
    static let animation: Animation = .linear(duration: 1.2)
        .delay(0.3)
        .repeatForever(autoreverses: false)
    static let gradient = Gradient(colors: [edgeGradientColor, shimmerColor, edgeGradientColor])
    
    private static let edgeGradientColor = Color.white.opacity(0)
    private static let shimmerColor = Color.white.opacity(0.6)
}
