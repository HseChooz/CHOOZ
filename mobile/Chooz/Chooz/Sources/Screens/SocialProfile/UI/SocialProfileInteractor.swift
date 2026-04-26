import Foundation

@MainActor
protocol SocialProfileInteractorDeps {
    var socialProfileService: SocialProfileService { get }
}

@MainActor
final class SocialProfileInteractor {
    
    // MARK: - Init
    
    init(
        deps: SocialProfileInteractorDeps,
        userId: String
    ) {
        self.deps = deps
        self.userId = userId
    }
    
    // MARK: - Internal Methods
    
    func requestProfile() async throws -> SocialProfilePayload {
        try await deps.socialProfileService.fetchProfile(userId: userId)
    }
    
    // MARK: - Private Properties
    
    private let deps: SocialProfileInteractorDeps
    private let userId: String
    
}
