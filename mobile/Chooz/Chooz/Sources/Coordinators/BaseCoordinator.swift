import UIKit

class BaseCoordinator<ControllerType>: Identifiable where ControllerType: UIViewController {
    
    // MARK: - Init
    
    init(presenter: ControllerType) { 
        self.presenter = presenter
    }
    
    // MARK: - Internal Properties
    
    let id = UUID()
    
    var presenter: ControllerType
    
    // MARK: - Internal Methods
    
    func start() {
        preconditionFailure("Start method not implemented")
    }
    
    // MARK: - Private Properties
    
    private(set) var childCoordinators = [UUID: Any]()
    
}

// MARK: - Child Coordinator Management

extension BaseCoordinator {
    
    func store<U: UIViewController>(coordinator: BaseCoordinator<U>) {
        let coordinatorExists = childCoordinators.contains(where: { (key, value) -> Bool in
            return key == coordinator.id
        })
        
        if !coordinatorExists {
            childCoordinators[coordinator.id] = coordinator
        }
    }
    
    func free<U: UIViewController>(coordinator: BaseCoordinator<U>) {
        let coordinatorExists = childCoordinators.contains(where: { (key, value) -> Bool in
            return key == coordinator.id
        })
        
        if coordinatorExists {
            childCoordinators[coordinator.id] = nil
        }
    }
    
    func freeAllChildCoordinators() {
        childCoordinators = [UUID: Any]()
    }
    
    func childCoordinator<T>(forKey key: UUID) -> T? {
        return childCoordinators.first(where: { $0.key == key })?.value as? T
    }
    
}
