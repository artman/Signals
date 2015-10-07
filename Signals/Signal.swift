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
public class Signal<T> {
    
    /// The number of times the signal has fired.
    public var fireCount: Int
    
    /// The last data that the signal was fired with.
    public var lastDataFired: T? = nil
    
    /// All the listeners listening to the Signal.
    public var listeners:[AnyObject] {
        get {
            return signalListeners.filter {
                if let _ = $0.listener {
                    return true
                }
                return false
            }.map {
                (signal) -> AnyObject in
                return signal.listener!
            }
        }
    }
    
    public init() {
        fireCount = 0
    }
    
    private var signalListeners = [SignalListener<T>]() // FIXME: Replace with Set once Swift 1.2 is out
    
    private func dumpCancelledListeners() {
        var removeListeners = false
        for signalListener in signalListeners {
            if signalListener.listener == nil {
                removeListeners = true
            }
        }
        if removeListeners {
            signalListeners = signalListeners.filter {
                if let _ = $0.listener {
                    return true
                }
                return false
            }
        }
    }
    
    /// Attaches a listener to the signal
    ///
    /// - parameter listener: The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// - parameter callback: The closure to invoke whenever the signal fires.
    public func listen(listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        dumpCancelledListeners()
        let signalListener = SignalListener<T>(listener: listener, callback: callback);
        signalListeners.append(signalListener)
        return signalListener
    }
    
    /// Attaches a listener to the signal that is removed after the signal has fired once
    ///
    /// - parameter listener: The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// - parameter callback: The closure to invoke when the signal fires for the first time.
    public func listenOnce(listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        let signalListener = self.listen(listener, callback: callback)
        signalListener.once = true
        return signalListener
    }
    
    /// Attaches a listener to the signal and invokes the callback immediately with the last data fired by the signal
    /// if it has fired at least once.
    ///
    /// - parameter listener: The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// - parameter callback: The closure to invoke whenever the signal fires.
    public func listenPast(listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        let signalListener = self.listen(listener, callback: callback)
        if fireCount > 0 {
            signalListener.callback(lastDataFired!)
        }
        return signalListener
    }

    /// Attaches a listener to the signal and invokes the callback immediately with the last data fired by the signal
    /// if it has fired at least once. If it has not been fired yet, it will continue listening until it fires for the
    /// first time
    ///
    /// - parameter listener: The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// - parameter callback: The closure to invoke whenever the signal fires.
    public func listenPastOnce(listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        let signalListener = self.listen(listener, callback: callback)
        if fireCount > 0 {
            signalListener.callback(lastDataFired!)
            signalListener.cancel()
        } else {
            signalListener.once = true
        }

        return signalListener
    }

    /// Fires the singal.
    ///
    /// - parameter data: The data to fire the signal with.
    public func fire(data: T) {
        fireCount++
        lastDataFired = data
        dumpCancelledListeners()
        
        var removeListeners = [Int: Bool]()
        for signalListener in signalListeners {
            if signalListener.filter == nil || signalListener.filter!(data) == true {
                if !signalListener.dispatch(data) {
                    let hash = (signalListener as AnyObject).hash
                    removeListeners[hash] = true
                }
            }
        }
        if (removeListeners.count > 0) {
            signalListeners = signalListeners.filter { signalListener in
                let hash = (signalListener as AnyObject).hash
                return removeListeners.indexForKey(hash) == nil
            }
        }
    }
    
    /// Removes an object as a listener of the Signal.
    ///
    /// - parameter listener: The listener to remove.
    public func removeListener(listener: AnyObject) {
        signalListeners = signalListeners.filter {
            if let definiteListener:AnyObject = $0.listener {
                return definiteListener !== listener
            }
            return false
        }
    }
    
    /// Removes all listeners from the Signal
    public func removeAllListeners() {
        signalListeners.removeAll(keepCapacity: false)
    }
}

/// A SignalLister represenents an instance and its association with a Signal.
public class SignalListener<T> {
    
    // The listener
    weak public var listener: AnyObject?
    
    /// Whether the listener should be removed once it observes the Signal firing once
    public var once = false
    
    private var delay: NSTimeInterval?
    private var queuedData: T?
    private var filter: ((T) -> Bool)?
    private var callback: (T) -> Void
    
    private init (listener: AnyObject, callback: (T) -> Void) {
        self.listener = listener
        self.callback = callback
    }
    
    private func dispatch(data: T) -> Bool {
        if listener != nil {
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
                    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(delay! * Double(NSEC_PER_SEC))),
                        dispatch_get_main_queue()) { [weak self] () -> Void in
                            if let definiteSelf = self {
                                let data = definiteSelf.queuedData!
                                definiteSelf.queuedData = nil
                                if definiteSelf.listener != nil {
                                    definiteSelf.callback(data)
                                }
                            }
                    }
                }
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
    /// :return: Returns self so you can chain calls.
    public func filter(filter: (T) -> Bool) -> SignalListener {
        self.filter = filter
        return self
    }
    
    /// Tells the listener to queue up all signal fires until the elapsed time has passed and only once dispatch the last received
    /// data. A delay of 0 will wait until the next runloop to dispatch the signal fire to the listener.
    /// - parameter delay: The number of seconds to delay dispatch
    /// :return: Returns self so you can chain calls.
    public func queueAndDelayBy(delay: NSTimeInterval) -> SignalListener {
        self.delay = delay
        return self
    }
    
    /// Cancels the listener. This will detach the listening object from the Signal.
    public func cancel() {
        self.listener = nil
    }
}

infix operator => { associativity left precedence 0 }

public func =><T> (signal: Signal<T>, data: T) -> Void {
    signal.fire(data)
}

