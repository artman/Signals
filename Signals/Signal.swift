//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

import Foundation
#if os(Linux)
import Dispatch
#endif

/// Create instances of `Signal` and assign them to public constants on your class for each event type that your
/// class fires.
final public class Signal<T> {
        
    public typealias SignalCallback = (T) -> Void
    public typealias SignalDispose = () -> Void
    
    /// The number of times the `Signal` has fired.
    public private(set) var fireCount: Int = 0
    
    /// Whether or not the `Signal` should retain a reference to the last data it was fired with. Defaults to false.
    public var retainLastData: Bool = false {
        didSet {
            if !retainLastData {
                lastDataFired = nil
            }
        }
    }
    
    /// The last data that the `Signal` was fired with. In order for the `Signal` to retain the last fired data, its
    /// `retainLastFired`-property needs to be set to true
    public private(set) var lastDataFired: T? = nil
    
    /// All the observers of to the `Signal`.
    public var observers:[AnyObject] {
        return signalListeners.flatMap { $0.observer }
    }
    
    private var signalListeners = [SignalSubscription<T>]()
    
    /// Initializer.
    /// 
    /// - parameter retainLastData: Whether or not the Signal should retain a reference to the last data it was fired 
    ///   with. Defaults to false.
    public init(retainLastData: Bool = false) {
        self.retainLastData = retainLastData
    }
    
    /// Subscribes an observer to the `Signal`.
    ///
    /// - parameter observer: The observer that subscribes to the `Signal`. Should the observer be deallocated, the
    ///   subscription is automatically cancelled.
    /// - parameter callback: The closure to invoke whenever the `Signal` fires.
    /// - returns: A `SignalSubscription` that can be used to cancel or filter the subscription.
    @discardableResult
    public func subscribe(with observer: AnyObject, dispose: SignalDispose? = nil, callback: @escaping SignalCallback) -> SignalSubscription<T> {
        flushCancelledListeners()
        let signalListener = SignalSubscription<T>(observer: observer, dispose: dispose, callback: callback);
        signalListeners.append(signalListener)
        return signalListener
    }
    
    
    /// Subscribes an observer to the `Signal`. The subscription is automatically canceled after the `Signal` has
    /// fired once.
    ///
    /// - parameter observer: The observer that subscribes to the `Signal`. Should the observer be deallocated, the
    ///   subscription is automatically cancelled.
    /// - parameter callback: The closure to invoke when the signal fires for the first time.
    @discardableResult
    public func subscribeOnce(with observer: AnyObject, callback: @escaping SignalCallback) -> SignalSubscription<T> {
        let signalListener = self.subscribe(with: observer, callback: callback)
        signalListener.once = true
        return signalListener
    }
    
    /// Subscribes an observer to the `Signal` and invokes its callback immediately with the last data fired by the
    /// `Signal` if it has fired at least once and if the `retainLastData` property has been set to true.
    ///
    /// - parameter observer: The observer that subscribes to the `Signal`. Should the observer be deallocated, the
    ///   subscription is automatically cancelled.
    /// - parameter callback: The closure to invoke whenever the `Signal` fires.
    @discardableResult
    public func subscribePast(with observer: AnyObject, callback: @escaping SignalCallback) -> SignalSubscription<T> {
        #if DEBUG
            signalsAssert(retainLastData, "can't subscribe to past events on Signal with retainLastData set to false")
        #endif
        let signalListener = self.subscribe(with: observer, callback: callback)
        if let lastDataFired = lastDataFired {
            signalListener.callback(lastDataFired)
        }
        return signalListener
    }
    
    /// Subscribes an observer to the `Signal` and invokes its callback immediately with the last data fired by the
    /// `Signal` if it has fired at least once and if the `retainLastData` property has been set to true. If it has
    /// not been fired yet, it will continue listening until it fires for the first time.
    ///
    /// - parameter observer: The observer that subscribes to the `Signal`. Should the observer be deallocated, the
    ///   subscription is automatically cancelled.
    /// - parameter callback: The closure to invoke whenever the signal fires.
    @discardableResult
    public func subscribePastOnce(with observer: AnyObject, callback: @escaping SignalCallback) -> SignalSubscription<T> {
        #if DEBUG
            signalsAssert(retainLastData, "can't subscribe to past events on Signal with retainLastData set to false")
        #endif
        let signalListener = self.subscribe(with: observer, callback: callback)
        if let lastDataFired = lastDataFired {
            signalListener.callback(lastDataFired)
            signalListener.cancel()
        } else {
            signalListener.once = true
        }
        return signalListener
    }
    
    /// Fires the `Signal`.
    ///
    /// - parameter data: The data to fire the `Signal` with.
    public func fire(_ data: T) {
        fireCount += 1
        lastDataFired = retainLastData ? data : nil
        flushCancelledListeners()
        
        for signalListener in signalListeners {
            if signalListener.filter == nil || signalListener.filter!(data) == true {
                _ = signalListener.dispatch(data: data)
            }
        }
    }
    
    /// Cancels all subscriptions for an observer.
    ///
    /// - parameter observer: The observer whose subscriptions to cancel
    public func cancelSubscription(for observer: AnyObject) {
        signalListeners = signalListeners.filter {
            if let definiteListener:AnyObject = $0.observer {
                return definiteListener !== observer
            }
            return false
        }
    }
    
    /// Cancels all subscriptions for the `Signal`.
    public func cancelAllSubscriptions() {
        signalListeners.removeAll(keepingCapacity: false)
    }
    
    /// Clears the last fired data from the `Signal` and resets the fire count.
    public func clearLastData() {
        lastDataFired = nil
    }
    
    // MARK: - Private Interface
    
    private func flushCancelledListeners() {
        var removeListeners = false
        for signalListener in signalListeners {
            if signalListener.observer == nil {
                removeListeners = true
            }
        }
        if removeListeners {
            signalListeners = signalListeners.filter {
                return $0.observer != nil
            }
        }
    }
}

/// A SignalLister represenents an instance and its association with a `Signal`.
public class SignalSubscription<T> {
    public typealias SignalCallback = (T) -> Void
    public typealias SignalFilter = (T) -> Bool
    public typealias SignalDispose = () -> Void
    
    // The observer.
    weak public var observer: AnyObject?
    
    /// Whether the observer should be removed once it observes the `Signal` firing once. Defaults to false.
    public var once = false
    
    fileprivate var queuedData: T?
    fileprivate var filter: SignalFilter?
    fileprivate var callback: SignalCallback
    fileprivate var dispose: SignalDispose?
    fileprivate var dispatchQueue: DispatchQueue?
    private var sampler: Sampler<T>?
    
    fileprivate init(observer: AnyObject, dispose: SignalDispose?, callback: @escaping SignalCallback) {
        self.observer = observer
        self.callback = callback
        self.dispose = dispose
    }
    
    deinit {
        if let dispose = dispose {
            if let dispatchQueue = dispatchQueue {
                dispatchQueue.async {
                    dispose()
                }
            } else {
                if #available(OSX 10.10, *) {
                    DispatchQueue.global().async {
                        dispose()
                    }
                } else {
                    DispatchQueue.global(priority: .default).async {
                        dispose()
                    }
                }
            }
        }
    }
    
    /// Assigns a filter to the `SignalSubscription`. This lets you define conditions under which a observer should actually
    /// receive the firing of a `Signal`. The closure that is passed an argument can decide whether the firing of a
    /// `Signal` should actually be dispatched to its observer depending on the data fired.
    ///
    /// If the closeure returns true, the observer is informed of the fire. The default implementation always
    /// returns `true`.
    ///
    /// - parameter predicate: A closure that can decide whether the `Signal` fire should be dispatched to its observer.
    /// - returns: Returns self so you can chain calls.
    @discardableResult
    public func filter(_ predicate: @escaping SignalFilter) -> SignalSubscription {
        self.filter = predicate
        return self
    }
    
    
    /// Tells the observer to sample received `Signal` data and only dispatch the latest data once the time interval 
    /// has elapsed. This is useful if the subscriber wants to throttle the amount of data it receives from the
    /// `Signal`.
    ///
    /// - parameter sampleInterval: The number of seconds to delay dispatch.
    /// - returns: Returns self so you can chain calls.
    @discardableResult
    public func sample(every sampleInterval: TimeInterval) -> SignalSubscription {
        if sampler == nil {
            sampler = Sampler()
            sampler?.fire = { [weak self] data in
                self?.sampledDispatch(data: data)
            }
            sampler?.dispatchQueue = dispatchQueue
        }
        sampler?.interval = sampleInterval
        return self
    }
    
    /// Assigns a dispatch queue to the `SignalSubscription`. The queue is used for scheduling the observer calls. If not
    /// nil, the callback is fired asynchronously on the specified queue. Otherwise, the block is run synchronously
    /// on the posting thread, which is its default behaviour.
    ///
    /// - parameter queue: A queue for performing the observer's calls.
    /// - returns: Returns self so you can chain calls.
    @discardableResult
    public func onQueue(_ queue: DispatchQueue) -> SignalSubscription {
        dispatchQueue = queue
        sampler?.dispatchQueue = queue
        return self
    }
    
    /// Cancels the observer. This will cancelSubscription the listening object from the `Signal`.
    public func cancel() {
        self.observer = nil
        if let dispose = self.dispose {
            if let dispatchQueue = dispatchQueue {
                dispatchQueue.async {
                    dispose()
                }
            } else {
                if #available(OSX 10.10, *) {
                    DispatchQueue.global().async {
                        dispose()
                    }
                } else {
                    DispatchQueue.global(priority: .default).async {
                        dispose()
                    }
                }
            }
        }
        self.dispose = nil
    }
    
    // MARK: - Internal Interface
    
    func dispatch(data: T) -> Bool {
        guard observer != nil else {
            return false
        }
        
        if once {
            observer = nil
        }
        
        if let sampler = sampler {
            sampler.enqueue(data: data)
        } else {
            if let queue = self.dispatchQueue {
                queue.async {
                    self.callback(data)
                }
            } else {
                callback(data)
            }
        }
        
        return observer != nil
    }
    
    private func sampledDispatch(data: T) {
        guard observer != nil else {
            return
        }
        
        if once {
            observer = nil
        }
        
        if let queue = dispatchQueue {
            queue.async {
                self.callback(data)
            }
        } else {
            callback(data)
        }
    }
}

infix operator => : AssignmentPrecedence

/// Helper operator to fire signal data.
public func =><T> (signal: Signal<T>, data: T) -> Void {
    signal.fire(data)
}

fileprivate func signalsAssert(_ condition: Bool, _ message: String) {
    #if DEBUG
        if let assertionHandlerOverride = assertionHandlerOverride {
            assertionHandlerOverride(condition, message)
            return
        }
    #endif
    assert(condition, message)
}

#if DEBUG
var assertionHandlerOverride:((_ condition: Bool, _ message: String) -> ())?
#endif

fileprivate class Sampler<T> {
    fileprivate var dispatchQueue: DispatchQueue?
    fileprivate var interval: TimeInterval = 0.0
    fileprivate var fireImmediately = true
    fileprivate var fire: ((T) -> Void)?
    private var queuedData: T?
    fileprivate func enqueue(data: T) {
        if queuedData == nil, fireImmediately {
            immediateFire(data: data)
        } else if queuedData != nil {
            queuedData = data
        } else {
            queuedData = data
            after { [weak self] () -> Void in
                self?.delayedFire()
            }
        }
    }
    private func immediateFire(data: T) {
        guard let fire = fire else {
            return
        }
        if let queue = dispatchQueue {
            queue.async {
                fire(data)
            }
        } else {
            fire(data)
        }
        fireImmediately = false
        after { [weak self] in
            self?.resetFireImmediately()
        }
    }
    private func resetFireImmediately() {
        guard queuedData == nil else {
            return
        }
        fireImmediately = true
    }
    private func delayedFire() {
        guard let fire = fire, let data = queuedData else {
            return
        }
        if let queue = dispatchQueue {
            queue.async {
                fire(data)
            }
        } else {
            fire(data)
        }
        queuedData = nil
        fireImmediately = false
        after { [weak self] in
            self?.resetFireImmediately()
        }
    }
    private func after(_ block: @escaping () -> Void) {
        let dispatchQueue = self.dispatchQueue ?? DispatchQueue.main
        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(interval * 1000))
        dispatchQueue.asyncAfter(deadline: deadline, execute: block)
    }
}
