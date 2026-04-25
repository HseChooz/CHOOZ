import Foundation
import Testing
@testable import Chooz

struct CollectionItemDetailsViewModelTests {
    
    @Test
    @MainActor
    func addToWishlist_updatesStateOptimisticallyAndCallsService() async {
        let payload = makePayload(isAdded: false)
        let interactor = CollectionItemDetailsInteractor(
            deps: StubCollectionItemDetailsInteractorDeps(
                collectionItemDetailsService: StubCollectionItemDetailsService(result: .success(payload))
            ),
            collectionSlug: "for-second-half",
            itemId: payload.id
        )
        let wishlistService = StubCollectionWishlistService(
            addResult: .success(()),
            removeResult: .success(())
        )
        let producer = CollectionWishlistActionPerformerProducer(
            deps: StubWishlistProducerDeps(
                collectionWishlistService: wishlistService,
                toastManager: ToastManager()
            )
        )
        let viewModel = CollectionItemDetailsViewModelImpl(
            interactor: interactor,
            viewStateBuilder: CollectionItemDetailsViewStateBuilder(),
            wishlistPerformer: producer.makePerformer(),
            wishlistReporter: producer.reporter
        )
        
        viewModel.requestCollectionItemDetails()
        await waitForLoadedState(on: viewModel)
        
        viewModel.addToWishlist(collectionItemId: payload.id)
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        #expect(loadedModel(from: viewModel.viewState)?.isAdded == true)
        
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(await wishlistService.addedIds() == [payload.id])
        #expect(loadedModel(from: viewModel.viewState)?.isAdded == true)
    }
    
    @Test
    @MainActor
    func removeFromWishlist_rollsBackStateWhenServiceFails() async {
        let payload = makePayload(isAdded: true)
        let interactor = CollectionItemDetailsInteractor(
            deps: StubCollectionItemDetailsInteractorDeps(
                collectionItemDetailsService: StubCollectionItemDetailsService(result: .success(payload))
            ),
            collectionSlug: "for-second-half",
            itemId: payload.id
        )
        let wishlistService = StubCollectionWishlistService(
            addResult: .success(()),
            removeResult: .failure(CollectionItemDetailsViewModelStubError.failed)
        )
        let producer = CollectionWishlistActionPerformerProducer(
            deps: StubWishlistProducerDeps(
                collectionWishlistService: wishlistService,
                toastManager: ToastManager()
            )
        )
        let viewModel = CollectionItemDetailsViewModelImpl(
            interactor: interactor,
            viewStateBuilder: CollectionItemDetailsViewStateBuilder(),
            wishlistPerformer: producer.makePerformer(),
            wishlistReporter: producer.reporter
        )
        
        viewModel.requestCollectionItemDetails()
        await waitForLoadedState(on: viewModel)
        
        viewModel.removeFromWishlist(collectionItemId: payload.id)
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        #expect(loadedModel(from: viewModel.viewState)?.isAdded == false)
        
        try? await Task.sleep(nanoseconds: 400_000_000)
        #expect(await wishlistService.removedIds() == [payload.id])
        #expect(loadedModel(from: viewModel.viewState)?.isAdded == true)
    }

    @Test
    @MainActor
    func openCollectionItemDetails_passesSharedWishlistDependenciesToRouter() async {
        let payload = makeCollectionPayload(firstItemIsAdded: false, secondItemIsAdded: false)
        let wishlistService = StubCollectionWishlistService(
            addResult: .success(()),
            removeResult: .success(())
        )
        let producer = CollectionWishlistActionPerformerProducer(
            deps: StubWishlistProducerDeps(
                collectionWishlistService: wishlistService,
                toastManager: ToastManager()
            )
        )
        let wishlistPerformer = producer.makePerformer()
        let wishlistReporter = producer.reporter
        let router = StubCollectionRouter()
        let viewModel = makeCollectionViewModel(
            payload: payload,
            router: router,
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        
        viewModel.requestCollection()
        await waitForLoadedState(on: viewModel)
        viewModel.openCollectionItemDetails(itemId: "collection-item-1")
        
        guard let destination = router.destination,
              case .collectionItemDetails(
            let collectionSlug,
            let itemId,
            let routedWishlistPerformer,
            let routedWishlistReporter
        ) = destination else {
            #expect(Bool(false))
            return
        }
        
        #expect(collectionSlug == payload.slug)
        #expect(itemId == "collection-item-1")
        #expect((routedWishlistPerformer as AnyObject) === (wishlistPerformer as AnyObject))
        #expect((routedWishlistReporter as AnyObject) === (wishlistReporter as AnyObject))
    }
    
    @Test
    @MainActor
    func addFromCollectionItemDetails_updatesOnlyTargetCollectionCardThroughSharedReporter() async {
        let collectionPayload = makeCollectionPayload(firstItemIsAdded: false, secondItemIsAdded: false)
        let wishPayload = makePayload(isAdded: false)
        let wishlistService = StubCollectionWishlistService(
            addResult: .success(()),
            removeResult: .success(())
        )
        let producer = CollectionWishlistActionPerformerProducer(
            deps: StubWishlistProducerDeps(
                collectionWishlistService: wishlistService,
                toastManager: ToastManager()
            )
        )
        let wishlistPerformer = producer.makePerformer()
        let wishlistReporter = producer.reporter
        let collectionViewModel = makeCollectionViewModel(
            payload: collectionPayload,
            router: StubCollectionRouter(),
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        let collectionItemDetailsViewModel = makeCollectionItemDetailsViewModel(
            payload: wishPayload,
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        
        collectionViewModel.requestCollection()
        collectionItemDetailsViewModel.requestCollectionItemDetails()
        await waitForLoadedState(on: collectionViewModel)
        await waitForLoadedState(on: collectionItemDetailsViewModel)
        
        collectionItemDetailsViewModel.addToWishlist(collectionItemId: wishPayload.id)
        
        #expect(await waitUntil {
            collectionCard(id: wishPayload.id, from: collectionViewModel.viewState)?.isAdded == true
        })
        #expect(collectionCard(id: "collection-item-2", from: collectionViewModel.viewState)?.isAdded == false)
        #expect(loadedModel(from: collectionItemDetailsViewModel.viewState)?.isAdded == true)
    }
    
    @Test
    @MainActor
    func removeFromCollectionItemDetails_updatesOnlyTargetCollectionCardThroughSharedReporter() async {
        let collectionPayload = makeCollectionPayload(firstItemIsAdded: true, secondItemIsAdded: true)
        let wishPayload = makePayload(isAdded: true)
        let wishlistService = StubCollectionWishlistService(
            addResult: .success(()),
            removeResult: .success(())
        )
        let producer = CollectionWishlistActionPerformerProducer(
            deps: StubWishlistProducerDeps(
                collectionWishlistService: wishlistService,
                toastManager: ToastManager()
            )
        )
        let wishlistPerformer = producer.makePerformer()
        let wishlistReporter = producer.reporter
        let collectionViewModel = makeCollectionViewModel(
            payload: collectionPayload,
            router: StubCollectionRouter(),
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        let collectionItemDetailsViewModel = makeCollectionItemDetailsViewModel(
            payload: wishPayload,
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        
        collectionViewModel.requestCollection()
        collectionItemDetailsViewModel.requestCollectionItemDetails()
        await waitForLoadedState(on: collectionViewModel)
        await waitForLoadedState(on: collectionItemDetailsViewModel)
        
        collectionItemDetailsViewModel.removeFromWishlist(collectionItemId: wishPayload.id)
        
        #expect(await waitUntil {
            collectionCard(id: wishPayload.id, from: collectionViewModel.viewState)?.isAdded == false
        })
        #expect(collectionCard(id: "collection-item-2", from: collectionViewModel.viewState)?.isAdded == true)
        #expect(loadedModel(from: collectionItemDetailsViewModel.viewState)?.isAdded == false)
    }
    
    @Test
    @MainActor
    func failedRemoveFromCollectionItemDetails_rollsBackCollectionCardThroughSharedReporter() async {
        let collectionPayload = makeCollectionPayload(firstItemIsAdded: true, secondItemIsAdded: false)
        let wishPayload = makePayload(isAdded: true)
        let wishlistService = StubCollectionWishlistService(
            addResult: .success(()),
            removeResult: .failure(CollectionItemDetailsViewModelStubError.failed),
            delayNanoseconds: 500_000_000
        )
        let producer = CollectionWishlistActionPerformerProducer(
            deps: StubWishlistProducerDeps(
                collectionWishlistService: wishlistService,
                toastManager: ToastManager()
            )
        )
        let wishlistPerformer = producer.makePerformer()
        let wishlistReporter = producer.reporter
        let collectionViewModel = makeCollectionViewModel(
            payload: collectionPayload,
            router: StubCollectionRouter(),
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        let collectionItemDetailsViewModel = makeCollectionItemDetailsViewModel(
            payload: wishPayload,
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
        
        collectionViewModel.requestCollection()
        collectionItemDetailsViewModel.requestCollectionItemDetails()
        await waitForLoadedState(on: collectionViewModel)
        await waitForLoadedState(on: collectionItemDetailsViewModel)
        
        collectionItemDetailsViewModel.removeFromWishlist(collectionItemId: wishPayload.id)
        
        #expect(await waitUntil {
            collectionCard(id: wishPayload.id, from: collectionViewModel.viewState)?.isAdded == false
            && loadedModel(from: collectionItemDetailsViewModel.viewState)?.isAdded == false
        })
        #expect(await waitUntil {
            collectionCard(id: wishPayload.id, from: collectionViewModel.viewState)?.isAdded == true
            && loadedModel(from: collectionItemDetailsViewModel.viewState)?.isAdded == true
        })
        #expect(collectionCard(id: "collection-item-2", from: collectionViewModel.viewState)?.isAdded == false)
    }
    
    // MARK: - Private Methods
    
    private func makePayload(isAdded: Bool) -> CollectionItemDetailsPayload {
        CollectionItemDetailsPayload(
            id: "collection-item-1",
            wishItemId: "wish-item-1",
            title: "Подарок",
            description: "Описание",
            link: URL(string: "https://example.com/wish"),
            price: "1990",
            currency: .rub,
            imageUrl: URL(string: "https://example.com/image.png"),
            isAdded: isAdded
        )
    }
    
    private func makeCollectionPayload(
        firstItemIsAdded: Bool,
        secondItemIsAdded: Bool
    ) -> CollectionPayload {
        CollectionPayload(
            id: "collection-1",
            slug: "for-second-half",
            title: "Подарки",
            subtitle: "Для вдохновения",
            description: "Описание подборки",
            badge: nil,
            coverImageUrl: nil,
            sectionKey: "gifts",
            sectionTitle: "Подборки",
            tags: ["Дом", "Хобби"],
            itemsCount: 2,
            items: [
                CollectionPayload.Item(
                    id: "collection-item-1",
                    title: "Подарок 1",
                    description: "Описание 1",
                    link: nil,
                    price: "1990",
                    currency: .rub,
                    tags: ["Дом"],
                    imageUrl: nil,
                    isAdded: firstItemIsAdded,
                    wishItemId: nil
                ),
                CollectionPayload.Item(
                    id: "collection-item-2",
                    title: "Подарок 2",
                    description: "Описание 2",
                    link: nil,
                    price: "2990",
                    currency: .rub,
                    tags: ["Хобби"],
                    imageUrl: nil,
                    isAdded: secondItemIsAdded,
                    wishItemId: nil
                )
            ]
        )
    }
    
    @MainActor
    private func makeCollectionViewModel(
        payload: CollectionPayload,
        router: any CollectionRouter,
        wishlistPerformer: any CollectionWishlistActionPerformer,
        wishlistReporter: any CollectionWishlistActionReporter
    ) -> CollectionViewModelImpl {
        let interactor = CollectionInteractor(
            deps: StubCollectionInteractorDeps(
                collectionService: StubCollectionService(result: .success(payload))
            ),
            slug: payload.slug
        )
        
        return CollectionViewModelImpl(
            interactor: interactor,
            router: router,
            viewStateBuilder: CollectionViewStateBuilder(),
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
    }
    
    @MainActor
    private func makeCollectionItemDetailsViewModel(
        payload: CollectionItemDetailsPayload,
        wishlistPerformer: any CollectionWishlistActionPerformer,
        wishlistReporter: any CollectionWishlistActionReporter
    ) -> CollectionItemDetailsViewModelImpl {
        let interactor = CollectionItemDetailsInteractor(
            deps: StubCollectionItemDetailsInteractorDeps(
                collectionItemDetailsService: StubCollectionItemDetailsService(result: .success(payload))
            ),
            collectionSlug: "for-second-half",
            itemId: payload.id
        )
        
        return CollectionItemDetailsViewModelImpl(
            interactor: interactor,
            viewStateBuilder: CollectionItemDetailsViewStateBuilder(),
            wishlistPerformer: wishlistPerformer,
            wishlistReporter: wishlistReporter
        )
    }
    
    private func loadedModel(from viewState: CollectionItemDetailsViewState) -> CollectionItemDetailsLoadedView.Model? {
        switch viewState {
        case .loaded(let model):
            return model
        case .loading, .error:
            return nil
        }
    }
    
    private func collectionCard(
        id: String,
        from viewState: CollectionViewState
    ) -> CollectionItemCardView.Model? {
        loadedCollectionModel(from: viewState)?.itemCards.first { $0.id == id }
    }
    
    private func loadedCollectionModel(from viewState: CollectionViewState) -> CollectionLoadedView.Model? {
        switch viewState {
        case .loaded(let model):
            return model
        case .loading, .error:
            return nil
        }
    }
    
    @MainActor
    private func waitForLoadedState(on viewModel: CollectionItemDetailsViewModelImpl) async {
        for _ in 0..<20 {
            if case .loaded = viewModel.viewState {
                return
            }
            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
    
    @MainActor
    private func waitForLoadedState(on viewModel: CollectionViewModelImpl) async {
        for _ in 0..<20 {
            if case .loaded = viewModel.viewState {
                return
            }
            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
    
    @MainActor
    private func waitUntil(_ predicate: @MainActor () -> Bool) async -> Bool {
        for _ in 0..<100 {
            if predicate() {
                return true
            }
            await Task.yield()
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        
        return predicate()
    }
    
}

@MainActor
private struct StubCollectionInteractorDeps: CollectionInteractorDeps {
    let collectionService: CollectionService
}

private struct StubCollectionService: CollectionService {
    let result: Result<CollectionPayload, Error>
    
    func fetchCollection(slug: String) async throws -> CollectionPayload {
        try result.get()
    }
}

@MainActor
private final class StubCollectionRouter: CollectionRouter {
    
    // MARK: - Internal Properties
    
    private(set) var destination: CollectiontDestination?
    
    // MARK: - CollectionRouter
    
    func routeTo(destination: CollectiontDestination) {
        self.destination = destination
    }
    
}

@MainActor
private struct StubWishlistProducerDeps: CollectionWishlistActionPerformerProducerDeps {
    let collectionWishlistService: CollectionWishlistService
    let toastManager: ToastManager
}

private actor StubCollectionWishlistService: CollectionWishlistService {
    
    // MARK: - Init
    
    init(
        addResult: Result<Void, Error>,
        removeResult: Result<Void, Error>,
        delayNanoseconds: UInt64 = 300_000_000
    ) {
        self.addResult = addResult
        self.removeResult = removeResult
        self.delayNanoseconds = delayNanoseconds
    }
    
    // MARK: - CollectionWishlistService
    
    func addToWishlist(collectionItemId: String) async throws {
        addedCollectionItemIds.append(collectionItemId)
        try await Task.sleep(nanoseconds: delayNanoseconds)
        try addResult.get()
    }
    
    func removeFromWishlist(collectionItemId: String) async throws {
        removedCollectionItemIds.append(collectionItemId)
        try await Task.sleep(nanoseconds: delayNanoseconds)
        try removeResult.get()
    }
    
    // MARK: - Internal Methods
    
    func addedIds() -> [String] {
        addedCollectionItemIds
    }
    
    func removedIds() -> [String] {
        removedCollectionItemIds
    }
    
    // MARK: - Private Properties
    
    private let addResult: Result<Void, Error>
    private let removeResult: Result<Void, Error>
    private let delayNanoseconds: UInt64
    
    private var addedCollectionItemIds: [String] = []
    private var removedCollectionItemIds: [String] = []
    
}

@MainActor
private struct StubCollectionItemDetailsInteractorDeps: CollectionItemDetailsInteractorDeps {
    let collectionItemDetailsService: CollectionItemDetailsService
}

private final class StubCollectionItemDetailsService: CollectionItemDetailsService {
    
    // MARK: - Init
    
    init(result: Result<CollectionItemDetailsPayload, Error>) {
        self.result = result
    }
    
    // MARK: - CollectionItemDetailsService
    
    func fetchCollectionItemDetails(collectionSlug: String, itemId: String) async throws -> CollectionItemDetailsPayload {
        try result.get()
    }
    
    // MARK: - Private Properties
    
    private let result: Result<CollectionItemDetailsPayload, Error>
    
}

private enum CollectionItemDetailsViewModelStubError: Error, Equatable {
    case failed
}
