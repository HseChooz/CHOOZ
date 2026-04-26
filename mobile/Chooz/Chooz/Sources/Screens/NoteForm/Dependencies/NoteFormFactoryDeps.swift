import Foundation

@MainActor
protocol NoteFormFactoryDeps {
    var toastManager: ToastManager { get }
}

@MainActor
struct NoteFormFactoryDepsImpl: NoteFormFactoryDeps {
    let toastManager: ToastManager
}
