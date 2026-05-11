import SwiftUI

struct OnboardingPageIndicatorView: View {
    
    // MARK: - Init
    
    init(totalPages: Int, currentPageIndex: Int) {
        self.totalPages = totalPages
        self.currentPageIndex = currentPageIndex
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 4.0) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPageIndex ? Colors.Neutral.grey800 : Colors.Neutral.grey300)
                    .frame(width: index == currentPageIndex ? 16.0 : 6.0, height: 6.0)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentPageIndex)
    }
    
    // MARK: - Private Properties
    
    private let totalPages: Int
    private let currentPageIndex: Int
}

#Preview {
    VStack(spacing: 20.0) {
        OnboardingPageIndicatorView(totalPages: 3, currentPageIndex: 0)
        OnboardingPageIndicatorView(totalPages: 3, currentPageIndex: 1)
        OnboardingPageIndicatorView(totalPages: 3, currentPageIndex: 2)
    }
}
