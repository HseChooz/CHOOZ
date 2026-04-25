import Foundation

@MainActor
protocol CollectionItemDetailsFactoryDeps:
    CollectionItemDetailsInteractorDeps
{}

@MainActor
struct CollectionItemDetailsFactoryDepsImpl: CollectionItemDetailsFactoryDeps {
    let collectionItemDetailsService: CollectionItemDetailsService
}
