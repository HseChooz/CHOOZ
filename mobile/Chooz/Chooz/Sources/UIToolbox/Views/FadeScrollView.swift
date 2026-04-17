import SwiftUI

struct FadeScrollView<Content: View>: View {
    
    // MARK: - Init
    
    init(
        fadePercentage: CGFloat = 0.2,
        smoothFadeDistance: CGFloat = 32,
        showsIndicators: Bool = false,
        maxHeight: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.fadePercentage = fadePercentage
        self.smoothFadeDistance = smoothFadeDistance
        self.showsIndicators = showsIndicators
        self.maxHeight = maxHeight
        self.content = content
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    Color.clear
                        .onGeometryChange(
                            for: ContentScrollMetrics.self,
                            of: {
                                ContentScrollMetrics(
                                    minY: $0.frame(in: .named(Self.scrollCoordinateSpaceName)).minY,
                                    height: $0.size.height
                                )
                            },
                            action: { metrics in
                                scrollOffset = -metrics.minY
                                contentHeight = metrics.height
                            }
                        )
                }
        }
        .coordinateSpace(name: Self.scrollCoordinateSpaceName)
        .scrollIndicators(showsIndicators ? .automatic : .hidden)
        .frame(maxHeight: maxHeight)
        .readSize(onChange: { viewportSize = $0 })
        .mask { dynamicFadeMask }
    }
    
    // MARK: - Private Properties
    
    private static var scrollCoordinateSpaceName: String { "FadeScrollView.scroll" }
    
    private let fadePercentage: CGFloat
    private let smoothFadeDistance: CGFloat
    private let showsIndicators: Bool
    private let maxHeight: CGFloat?
    @ViewBuilder private let content: () -> Content
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var viewportSize: CGSize = .zero
    
    private var viewportHeight: CGFloat {
        viewportSize.height
    }
    
    private var smoothRamp: CGFloat {
        max(1, smoothFadeDistance)
    }
    
    private var topEdgeOpacity: CGFloat {
        guard viewportHeight > 0, contentHeight > 0 else { return 1 }
        if viewportHeight >= contentHeight || scrollOffset <= 0 {
            return 1
        }
        return min(1, max(0, 1 - scrollOffset / smoothRamp))
    }
    
    private var bottomEdgeOpacity: CGFloat {
        guard viewportHeight > 0, contentHeight > 0 else { return 1 }
        if viewportHeight >= contentHeight {
            return 1
        }
        let remaining = contentHeight - scrollOffset - viewportHeight
        if remaining <= 0 {
            return 1
        }
        return min(1, max(0, 1 - remaining / smoothRamp))
    }
    
    private var dynamicFadeMask: LinearGradient {
        let topStop = min(fadePercentage, 1 - fadePercentage)
        let bottomStop = max(fadePercentage, 1 - fadePercentage)
        return LinearGradient(
            stops: [
                .init(color: .white.opacity(topEdgeOpacity), location: 0),
                .init(color: .white, location: topStop),
                .init(color: .white, location: bottomStop),
                .init(color: .white.opacity(bottomEdgeOpacity), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - ContentScrollMetrics

private struct ContentScrollMetrics: Equatable {
    let minY: CGFloat
    let height: CGFloat
}
