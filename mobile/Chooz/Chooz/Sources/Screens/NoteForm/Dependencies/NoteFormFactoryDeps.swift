import Foundation

@MainActor
protocol NoteFormFactoryDeps {
    var toastManager: ToastManager { get }
    var analyticsService: AnalyticsService { get }
}

@MainActor
struct NoteFormFactoryDepsImpl: NoteFormFactoryDeps {
    let toastManager: ToastManager
    let analyticsService: AnalyticsService
}
