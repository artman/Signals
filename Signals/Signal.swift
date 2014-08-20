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
    
    /// Attach a listener to the signal
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke whenever the signal fires.
    public func listen(listener: AnyObject, callback: (T) -> Void) {
        var signalListener = SignalListener<T>(listener: listener, callback: callback);
        signalListeners.append(signalListener)
    }
    
    /// Attach a listener to the signal that is removed after the signal has fired once
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke when the signal fires for the first time.
    public func listenOnce(listener: AnyObject, callback: (T) -> Void) {
        var signalListener = SignalListener<T>(listener: listener, callback: callback);
        signalListener.once = true
        signalListeners.append(signalListener)
    }
    
    /// Fires the singal.
    ///
    /// :param: params The parameters to fire the signal with.
    public func fire(params: T) {
        signalListeners = signalListeners.filter {
            if let definiteListener: AnyObject = $0.listener {
                return true
            }
            return false
        }

        var index = 0
        for listener in signalListeners {
            if listener.once {
                signalListeners.removeAtIndex(index--)
            }
            listener.callback(params)
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

/// MARK: - Private

private class SignalListener<T> {
    
    weak var listener: AnyObject?
    var callback: (T) -> Void
    var once = false
    
    init (listener: AnyObject, callback: (T) -> Void) {
        self.listener = listener
        self.callback = callback
    }
}
