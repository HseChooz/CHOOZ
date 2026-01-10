import SwiftUI
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    
    var currentPageIndex: Int = 0
    
    func incrementPageIndex() {
        currentPageIndex += 1
    }
    
    func decrementPageIndex() {
        currentPageIndex -= 1
    }
}
