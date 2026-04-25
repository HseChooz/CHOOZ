import Foundation

struct WeakArray<Element: AnyObject> {

    // MARK: - Internal Properties

    var elements: [Element] {
        storage.compactMap { $0.value }
    }

    // MARK: - Internal Methods

    mutating func append(_ element: Element) {
        compact()
        storage.append(WeakBox(element))
    }

    mutating func remove(_ element: Element) {
        storage.removeAll { $0.value === element }
    }

    // MARK: - Private Types

    private struct WeakBox {
        weak var value: Element?

        init(_ value: Element) {
            self.value = value
        }
    }

    // MARK: - Private Properties

    private var storage: [WeakBox] = []

    // MARK: - Private Methods

    private mutating func compact() {
        storage.removeAll { $0.value == nil }
    }

}
