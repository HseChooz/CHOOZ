import UIKit

extension UITraitEnvironment {
    
    public var currentInterfaceLayout: InterfaceLayout {
        #if DEBUG && targetEnvironment(simulator)
        return overrideInterfaceLayout ?? InterfaceLayout()
        #else
        return InterfaceLayout()
        #endif
    }
    
}

#if DEBUG && targetEnvironment(simulator)

extension UITraitEnvironment {
    
    public var overrideInterfaceLayout: InterfaceLayout? {
        get {
            objc_getAssociatedObject(
                self as AnyObject,
                &AssociatedObjectKeys.overrideInterfaceLayout
            ) as? InterfaceLayout
        }
        set {
            objc_setAssociatedObject(
                self as AnyObject,
                &AssociatedObjectKeys.overrideInterfaceLayout,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
}

private enum AssociatedObjectKeys {
    static var overrideInterfaceLayout: UInt8 = .zero
}

#endif

extension UIScreen {

    // MARK: - Internal Properties

    @MainActor
    var currentInterfaceLayout: InterfaceLayout {
        InterfaceLayout(screenSize: bounds.size)
    }

}
