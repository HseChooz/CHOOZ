import UIKit

@MainActor
protocol AppTabBarDeps: AppTabBarControllerDeps {}

@MainActor
struct AppTabBarDepsImpl: AppTabBarDeps {
    let appRouter: AppRouter
    let mainTabViewController: UIViewController
    let calendarViewController: UIViewController
    let notesTabViewController: UIViewController
}
