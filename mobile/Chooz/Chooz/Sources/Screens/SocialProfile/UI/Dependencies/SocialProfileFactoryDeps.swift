import Foundation

@MainActor
protocol SocialProfileFactoryDeps:
    SocialProfileInteractorDeps,
    SocialProfileRouterDeps
{
    var analyticsService: AnalyticsService { get }
}

@MainActor
struct SocialProfileFactoryDepsImpl: SocialProfileFactoryDeps {
    let socialProfileService: SocialProfileService
    let appRouter: AppRouter
    let analyticsService: AnalyticsService
}
