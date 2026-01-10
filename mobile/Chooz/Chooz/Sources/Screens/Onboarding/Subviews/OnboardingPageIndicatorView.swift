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
                    .fill(index == currentPageIndex ? Colors.Blue.blue500 : Colors.Neutral.grey600)
                    .frame(width: index == currentPageIndex ? 45.0 : 12.0, height: 12.0)
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
