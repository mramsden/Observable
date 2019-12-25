import Foundation

private struct ObserverEntry<T>: Hashable {

    let identifier: String
    let observer: AnyObject
    let queue: DispatchQueue
    let block: (_: T, _: T) -> Void

    init(observer: AnyObject, queue: DispatchQueue, block: @escaping (_: T, _: T) -> Void) {
        identifier = UUID().uuidString
        self.observer = observer
        self.queue = queue
        self.block = block
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: ObserverEntry, rhs: ObserverEntry) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

public final class Observable<T> {

    typealias OldValue = T
    typealias NewValue = T
    typealias ObserverBlock = (_: OldValue, _: NewValue) -> Void

    private let observersQueue: DispatchQueue
    private var observers = Set<ObserverEntry<T>>()

    public init(_ value: T, identifier: UUID = UUID()) {
        self.value = value
        self.observersQueue = DispatchQueue(label: "com.bitsden.observable.\(identifier)")
    }

    public var value: T {
        didSet { notifyObservers(oldValue: oldValue, newValue: value) }
    }

    public func post(_ value: T) {
        DispatchQueue.main.async {
            self.value = value
        }
    }

    fileprivate func subscribe(
        observer: AnyObject,
        initial: Bool = false,
        queue: DispatchQueue = .main,
        block: @escaping ObserverBlock
    ) {
        observersQueue.async { [weak self] in
            guard let self = self else { return }
            self.observers.insert(ObserverEntry(observer: observer, queue: queue, block: block))
            if initial {
                let value = self.value
                queue.async {
                    block(value, value)
                }
            }
        }
    }

    public func unsubscribe(observer: AnyObject) {
        observersQueue.async { [weak self] in
            guard let self = self else { return }
            self.observers = self.observers.filter { entry in
                entry.observer !== observer
            }
        }
    }

    private func notifyObservers(oldValue: T, newValue: T) {
        observersQueue.async { [weak self] in
            guard let self = self else { return }
            self.observers.forEach { entry in
                entry.queue.async {
                    entry.block(oldValue, newValue)
                }
            }
        }
    }
}

private class ObservableBinding<T> {

    init(
        observable: Observable<T>,
        initial: Bool = false,
        queue: DispatchQueue = .main,
        block: @escaping (T, T) -> Void
    ) {
        observable.subscribe(
            observer: self,
            initial: initial,
            queue: queue,
            block: block
        )
    }
}

@discardableResult
public func bindObservable<T>(
    _ observable: Observable<T>,
    initial: Bool = false,
    queue: DispatchQueue = .main,
    block: @escaping (T, T) -> Void
) -> AnyObject {
    ObservableBinding(
        observable: observable,
        initial: initial,
        queue: queue,
        block: block
    )
}
