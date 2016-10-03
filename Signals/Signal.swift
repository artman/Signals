//
//  Signal.swift
//  Signals
//
//  Created by Tuomas Artman on 8/16/2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation

/// Create instances of Signal and assign them to public constants on your class for each event type that can
/// be observed by listeners.
final public class Signal<T> {
    public typealias SignalCallback = (T) -> Void
    
    /// The number of times the signal has fired.
    public fileprivate(set) var fireCount: Int = 0
    
    /// The last data that the signal was fired with.
    public fileprivate(set) var lastDataFired: T? = nil
    
    /// Whether or not the Signal should retain a reference to the last data it was fired with. Defaults to false.
    public var retainLastData: Bool = false {
        didSet {
            if !retainLastData {
                lastDataFired = nil
            }
        }
    }
    
    /// All the listeners listening to the Signal.
    public var listeners:[AnyObject] {
        get {
            return signalListeners.filter {
                return $0.listener != nil
            }.map {
                (signal) -> AnyObject in
                return signal.listener!
            }
        }
    }
    
    /// Initializer.
    /// 
    /// - parameter retainLastData: Whether or not the Signal should retain a reference to the last data it was fired 
    ///   with. Defaults to false.
    public init(retainLastData: Bool = false) {
        fireCount = 0
        self.retainLastData = retainLastData
    }
    
    fileprivate var signalListeners = [SignalListener<T>]()
    
    fileprivate func dumpCancelledListeners() {
        var removeListeners = false
        for signalListener in signalListeners {
            if signalListener.listener == nil {
                removeListeners = true
            }
        }
        if removeListeners {
            signalListeners = signalListeners.filter {
                return $0.listener != nil
            }
        }
    }
    
    /// Attaches a listener to the signal.
    ///
    /// - parameter on: The listener object. Sould the listener be deallocated, its associated callback is
    ///   automatically removed.
    /// - parameter callback: The closure to invoke whenever the signal fires.
    #if swift(>=3.0)
    @discardableResult
    public func listen(on listener: AnyObject, callback: @escaping SignalCallback) -> SignalListener<T> {
        dumpCancelledListeners()
        let signalListener = SignalListener<T>(listener: listener, callback: callback);
        signalListeners.append(signalListener)
        return signalListener
    }
    #else
    public func listen(on listener: AnyObject, callback: SignalCallback) -> SignalListener<T> {
        dumpCancelledListeners()
        let signalListener = SignalListener<T>(listener: listener, callback: callback);
        signalListeners.append(signalListener)
        return signalListener
    }
    #endif
    
    
    /// Attaches a listener to the signal that is removed after the signal has fired once.
    ///
    /// - parameter on: The listener object. Sould the listener be deallocated, its associated callback is
    ///   automatically removed.
    /// - parameter callback: The closure to invoke when the signal fires for the first time.
    #if swift(>=3.0)
    @discardableResult
    public func listenOnce(on listener: AnyObject, callback: @escaping SignalCallback) -> SignalListener<T> {
        let signalListener = self.listen(on: listener, callback: callback)
        signalListener.once = true
        return signalListener
    }
    #else
    public func listenOnce(on listener: AnyObject, callback: SignalCallback) -> SignalListener<T> {
    let signalListener = self.listen(on: listener, callback: callback)
    signalListener.once = true
    return signalListener
    }
    #endif
    
    /// Attaches a listener to the signal and invokes the callback immediately with the last data fired by the signal
    /// if it has fired at least once and if the `retainLastData` property has been set to true.
    ///
    /// - parameter on: The listener object. Sould the listener be deallocated, its associated callback is
    ///   automatically removed.
    /// - parameter callback: The closure to invoke whenever the signal fires.
    #if swift(>=3.0)
    @discardableResult
    public func listenPast(on listener: AnyObject, callback: @escaping SignalCallback) -> SignalListener<T> {
        let signalListener = self.listen(on: listener, callback: callback)
        if let lastDataFired = lastDataFired {
            signalListener.callback(lastDataFired)
        }
        return signalListener
    }
    #else
    public func listenPast(on listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        let signalListener = self.listen(on: listener, callback: callback)
        if let lastDataFired = lastDataFired {
            signalListener.callback(lastDataFired)
        }
        return signalListener
    }
    #endif

    /// Attaches a listener to the signal and invokes the callback immediately with the last data fired by the signal
    /// if it has fired at least once and if the `retainLastData` property has been set to true. If it has not been 
    /// fired yet, it will continue listening until it fires for the first time.
    ///
    /// - parameter listener: The listener object. Sould the listener be deallocated, its associated callback is 
    ///   automatically removed.
    /// - parameter callback: The closure to invoke whenever the signal fires.
    #if swift(>=3.0)
    @discardableResult
    public func listenPastOnce(on listener: AnyObject, callback: @escaping SignalCallback) -> SignalListener<T> {
        let signalListener = self.listen(on: listener, callback: callback)
        if let lastDataFired = lastDataFired {
            signalListener.callback(lastDataFired)
            signalListener.cancel()
        } else {
            signalListener.once = true
        }
        return signalListener
    }
    #else
    public func listenPastOnce(on listener: AnyObject, callback: SignalCallback) -> SignalListener<T> {
        let signalListener = self.listen(on: listener, callback: callback)
        if let lastDataFired = lastDataFired {
            signalListener.callback(lastDataFired)
            signalListener.cancel()
        } else {
            signalListener.once = true
        }
        return signalListener
    }
    #endif

    /// Fires the singal.
    ///
    /// - parameter data: The data to fire the signal with.
    #if swift(>=3.0)
    public func fire(_ data: T) {
        fireCount += 1
        lastDataFired = retainLastData ? data : nil
        dumpCancelledListeners()
        
        for signalListener in signalListeners {
            if signalListener.filter == nil || signalListener.filter!(data) == true {
                    _ = signalListener.dispatch(data)
            }
        }
    }
    #else
    public func fire(_ data: T) {
        fireCount += 1
        lastDataFired = retainLastData ? data : nil
        dumpCancelledListeners()
        
        for signalListener in signalListeners {
            if signalListener.filter == nil || signalListener.filter!(data) == true {
                _ = signalListener.dispatch(data)
            }
        }
    }
    #endif
    
    public func dettach(from listener: AnyObject) {
        signalListeners = signalListeners.filter {
            if let definiteListener:AnyObject = $0.listener {
                return definiteListener !== listener
            }
            return false
        }
    }
    
    /// Removes all listeners from the Signal.
    public func dettachAllListeners() {
        #if swift(>=3.0)
            signalListeners.removeAll(keepingCapacity: false)
        #else
            signalListeners.removeAll(keepingCapacity: false)
        #endif
    }
    
    /// Clears the last fired data from the Signal and resets the fire count.
    public func clearLastData() {
        lastDataFired = nil
    }
}

/// A SignalLister represenents an instance and its association with a Signal.
open class SignalListener<T> {
    public typealias SignalCallback = (T) -> Void
    public typealias SignalFilter = (T) -> Bool
    
    // The listener
    weak open var listener: AnyObject?
    
    /// Whether the listener should be removed once it observes the Signal firing once. Defaults to false.
    open var once = false
    
    #if swift(>=3.0)
        private var delay: TimeInterval?
    #else
        fileprivate var delay: TimeInterval?
    #endif
    var queuedData: T?
    var filter: (SignalFilter)?
    var callback: SignalCallback
    
    #if swift(>=3.0)
        private var dispatchQueue: DispatchQueue?
    #else
        fileprivate var dispatchQueue: DispatchQueue?
    #endif
    
    #if swift(>=3.0)
    init (listener: AnyObject, callback: @escaping SignalCallback) {
        self.listener = listener
        self.callback = callback
    }
    #else
    init (listener: AnyObject, callback: SignalCallback) {
        self.listener = listener
        self.callback = callback
    }
    #endif
    
    func dispatch(_ data: T) -> Bool {
        guard listener != nil else {
            return false
        }
        
        if once {
            listener = nil
        }
        
        if delay != nil {
            if queuedData != nil {
                // Already queueing
                queuedData = data
            } else {
                // Set up queue
                queuedData = data
                let block = { [weak self] () -> Void in
                    if let definiteSelf = self {
                        let data = definiteSelf.queuedData!
                        definiteSelf.queuedData = nil
                        if definiteSelf.listener != nil {
                            definiteSelf.callback(data)
                        }
                    }
                }
                #if swift(>=3.0)
                    let dispatchQueue = self.dispatchQueue ?? DispatchQueue.main
                    dispatchQueue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay! * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
                #else
                    #if swift(>=2.3)
                        let dispatchQueue = self.dispatchQueue ?? dispatch_get_main_queue()
                    #else
                        let dispatchQueue = self.dispatchQueue ?? DispatchQueue.main!
                    #endif
                    dispatchQueue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay! * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
                    
                #endif
            }
        } else {
            if let queue = self.dispatchQueue {
                #if swift(>=3.0)
                    queue.async {
                        self.callback(data)
                    }
                #else
                    queue.async {
                        self.callback(data)
                    }
                #endif
            } else {
                callback(data)
            }
        }
        
        return listener != nil
    }
    
    /// Assigns a filter to the SignalListener. This lets you define conditions under which a listener should actually
    /// receive the firing of a Singal. The closure that is passed an argument can decide whether the firing of a Signal
    /// should actually be dispatched to its listener depending on the data fired.
    ///
    /// If the closeure returns true, the listener is informed of the fire. The default implementation always
    /// returns true.
    ///
    /// - parameter filter: A closure that can decide whether the Signal fire should be dispatched to its listener.
    /// - returns: Returns self so you can chain calls.
  
    #if swift(>=3.0)
    @discardableResult
    public func filter(where predicate: @escaping SignalFilter) -> SignalListener {
        self.filter = predicate
        return self
    }
    #else
    open func filter(where predicate: SignalFilter) -> SignalListener {
        self.filter = predicate
        return self
    }
    #endif
    
    /// Tells the listener to queue up all signal fires until the elapsed time has passed and only once dispatch the 
    /// last received data. A delay of 0 will wait until the next runloop to dispatch the signal fire to the listener.
    /// - parameter delay: The number of seconds to delay dispatch
    /// - returns: Returns self so you can chain calls.
    #if swift(>=3.0)
    @discardableResult
    public func queue(andDelayBy delay: TimeInterval) -> SignalListener {
        self.delay = delay
        return self
    }
    #else
    open func queue(andDelayBy delay: TimeInterval) -> SignalListener {
        self.delay = delay
        return self
    }
    #endif

    /// Assigns a dispatch queue to the SignalListener. The queue is used for scheduling the listener calls. If not nil,
    /// the callback is fired asynchronously on the specified queue. Otherwise, the block is run synchronously on the
    /// posting thread (default behaviour).
    ///
    /// - parameter queue: A queue for performing the listener's calls.
    /// - returns: Returns self so you can chain calls.
    #if swift(>=3.0)
    @discardableResult
    public func dispatch(onQueue queue: DispatchQueue) -> SignalListener {
        self.dispatchQueue = queue
        return self
    }
    #else
    open func dispatch(onQueue queue: DispatchQueue) -> SignalListener {
        self.dispatchQueue = queue
        return self
    }
    #endif
    
    /// Cancels the listener. This will detach the listening object from the Signal.
    open func cancel() {
        self.listener = nil
    }
}


infix operator => : AssignmentPrecedence

public func =><T> (signal: Signal<T>, data: T) -> Void {
    signal.fire(data)
}
