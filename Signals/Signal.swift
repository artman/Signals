//
//  Signal.swift
//  Signals
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation

/// Create instances of Signal and assign them to public constants on your class for each event type that can
/// be observed by listeners.
public class Signal<T> {
    
    /// The number of times the signal has fired.
    public var fireCount = 0
    
    /// The last data that the signal was fired with.
    public var lastDataFired: T? = nil
    
    /// All the listeners listening to the Signal.
    public var listeners:[AnyObject] {
        get {
            return signalListeners.filter {
                if let definiteListener: AnyObject = $0.listener {
                    return true
                }
                return false
            }.map {
                (signal: SignalListener) -> AnyObject in
                return signal.listener!
            }
        }
    }
    
    private var signalListeners = [SignalListener<T>]()
    
    /// Attaches a listener to the signal
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke whenever the signal fires.
    public func listen(listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        var signalListener = SignalListener<T>(listener: listener, callback: callback);
        signalListeners.append(signalListener)
        return signalListener
    }
    
    /// Attaches a listener to the signal that is removed after the signal has fired once
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke when the signal fires for the first time.
    public func listenOnce(listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        var signalListener = self.listen(listener, callback: callback)
        signalListener.once = true
        return signalListener
    }
    
    /// Attaches a listener to the signal and invokes the callback immediately with the last data fired by the signal
    /// if it has fired at least once.
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke whenever the signal fires.
    public func listenPast(listener: AnyObject, callback: (T) -> Void) -> SignalListener<T> {
        var signalListener = self.listen(listener, callback: callback)
        if fireCount > 0 {
            signalListener.callback(lastDataFired!)
        }
        return signalListener
    }
        
    /// Fires the singal.
    ///
    /// :param: data The data to fire the signal with.
    public func fire(data: T) {
        fireCount++
        lastDataFired = data
        signalListeners = signalListeners.filter {
            if let definiteListener: AnyObject = $0.listener {
                return true
            }
            return false
        }

        var index = 0
        
        for listener in (signalListeners.filter {return $0.filter(data)}) {
            if listener.once {
                signalListeners.removeAtIndex(index--)
            }
            listener.callback(data)
            index++
        }
    }
    
    /// Removes an object as a listener of the Signal.
    ///
    /// :param: listener The listener to remove.
    public func removeListener(listener: AnyObject) {
        signalListeners = signalListeners.filter {
            if let definiteListener:AnyObject = $0.listener {
                return definiteListener.hash != listener.hash
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
    
    weak public var listener: AnyObject?
    private var callback: (T) -> Void
    
    /// Whether the listener should be removed once it observes the Signal firing once
    public var once = false
    
    /// A closure that can decide whether the a Singal fireing should actually be dispatched to its listener.
    /// If the closeure returns true, the listener is informed of the fire. The default implementation always
    /// returns true.
    ///
    /// This is useful to implement conditional listeners that are interested in hearing about certain types of data
    /// being fired by the Singal.
    private var filter: (T) -> Bool = {T in return true}
    
    private init (listener: AnyObject, callback: (T) -> Void) {
        self.listener = listener
        self.callback = callback
    }
    
    public func setFilter(filter: (T) -> Bool) {
        self.filter = filter
    }
}
