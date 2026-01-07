import Foundation
import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    
    // MARK: - Init

    init(scaleEffect: CGFloat = 0.96, duration: Double = 0.15) {
        self.scaleEffect = scaleEffect
        self.animation = .easeInOut(duration: duration)
    }
    
    // MARK: - Public Methods

    func makeBody(configuration: Self.Configuration) -> some View {
        let scale = scaleValue(for: configuration.isPressed)
        return configuration.label
            .onHover { isHovered = $0 }
            .scaleEffect(scale)
            .animation(animation, value: scale)
    }
    
    // MARK: - Private Properties

    @State private var isHovered: Bool = false
    private let scaleEffect: CGFloat
    private let animation: Animation
    
    // MARK: - Private Methods

    private func scaleValue(for isPressed: Bool) -> CGFloat {
        let hoverScale = isHovered ? scaleEffect : 1.0
        let pressScale = isPressed ? scaleEffect : 1.0
        return hoverScale * pressScale
    }
}
