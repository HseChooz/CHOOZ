#if os(iOS)

public struct InterfaceLayoutValue<T: Sendable>: Sendable {

    // MARK: - Init

    public init(valueProvider: @escaping @Sendable (InterfaceLayout) -> T) {
        self.valueProvider = valueProvider
    }

    // MARK: - Public Methods

    public func value(for interfaceLayout: InterfaceLayout) -> T {
        return valueProvider(interfaceLayout)
    }

    // MARK: - Private Properties

    private let valueProvider: @Sendable (InterfaceLayout) -> T

}

// MARK: - Convenience Accessors

extension InterfaceLayoutValue {

    public var large: T {
        return value(for: .large(.portrait))
    }

    public var compact: T {
        return value(for: .compact(.standard, .portrait))
    }

    public var largeLanscape: T {
        return value(for: .large(.landscape))
    }

    public var compactLandcape: T {
        return value(for: .compact(.standard, .landscape))
    }

    public var compactSmall: T {
        return value(for: .compact(.small, .portrait))
    }

    public var compactSmallLandscape: T {
        return value(for: .compact(.small, .landscape))
    }

}

// MARK: - ForEach

extension InterfaceLayoutValue {

    public func forEach(_ block: (InterfaceLayout, T) -> Void) {
        for caseItem in InterfaceLayout.allCases {
            block(caseItem, value(for: caseItem))
        }
    }

}

// MARK: - Convenience Initializers

extension InterfaceLayoutValue {

    public init(small: T, others: T) {
        self = InterfaceLayoutValue(valueProvider: { interfaceLayout in
            switch interfaceLayout {
            case .compact(.small, _):
                return small
            case .large, .compact:
                return others
            }
        })
    }

    public init(large: T, compact: T) {
        self.init { interfaceLayout in
            switch interfaceLayout {
            case .large:
                return large
            case .compact:
                return compact
            }
        }
    }

    public init(large: T, compact: T, small: T) {
        self.init { interfaceLayout in
            switch interfaceLayout {
            case .large:
                return large
            case .compact(.standard, _):
                return compact
            case .compact(.small, _):
                return small
            }
        }
    }

    public init(largeLandscape: T, others: T) {
        self.init { interfaceLayout in
            switch interfaceLayout {
            case .large(.landscape):
                return largeLandscape
            case .large(.portrait):
                return others
            case .compact:
                return others
            }
        }
    }

    public init(largeLandscape: T, largePortrait: T, compact: T) {
        self.init { interfaceLayout in
            switch interfaceLayout {
            case .large(.landscape):
                return largeLandscape
            case .large(.portrait):
                return largePortrait
            case .compact:
                return compact
            }
        }
    }

    public init(compactPortrait: T, compactLandscape: T, large: T) {
        self.init { interfaceLayout in
            switch interfaceLayout {
            case .large:
                return large
            case .compact(_, .landscape):
                return compactLandscape
            case .compact(_, .portrait):
                return compactPortrait
            }
        }
    }

    public init(compactPortrait: T, others: T) {
        self.init { interfaceLayout in
            switch interfaceLayout {
            case .large:
                return others
            case .compact(_, .landscape):
                return others
            case .compact(_, .portrait):
                return compactPortrait
            }
        }
    }

    public init(allCases: T) {
        self.init { _ in
            return allCases
        }
    }

}

#endif
