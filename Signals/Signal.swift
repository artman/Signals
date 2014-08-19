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
class Signal<T> {
    
    /// All the listeners listening to the Signal.
    var listeners:[AnyObject] {
        get {
            return signalListeners.filter {
                if let definiteListener:AnyObject = $0.listener {
                    return true
                }
                return false
            }.map {
                (signal:SignalListener) -> AnyObject in
                return signal.listener!
            }
        }
    }
    
    private var signalListeners = [SignalListener<T>]()
    
    
    /// Attach a listener to the signal
    ///
    /// :param: listener The listener object. Sould the listener be deallocated, its associated callback is automatically removed.
    /// :param: callback The closure to invoke whenever the signal fires.
    func listen(listener:AnyObject, callback: (T)->Void) {
        var signalListener = SignalListener<T>(listener:listener, callback:callback);
        signalListeners.append(signalListener)
    }
    
    /// Fires the singal.
    ///
    /// :param: params The parameters to fire the signal with.
    func fire(params:T) {
        signalListeners = signalListeners.filter {
            if let definiteListener:AnyObject = $0.listener {
                return true
            }
            return false
        }

        for listener in signalListeners {
            listener.callback(params)
        }
    }
    
    /// Removes an object as a listener of the Signal.
    ///
    /// :param: listener The listener to remove.
    func removeListener(listener: AnyObject) {
        signalListeners = signalListeners.filter {
            if let definiteListener:AnyObject = $0.listener {
                return definiteListener.hash != listener.hash
            }
            return false
        }
    }
    
    /// Removes all listeners from the Signal
    func removeAllListener() {
        signalListeners.removeAll(keepCapacity: false)
    }
}

/// MARK: - Private

private class SignalListener<T> {
    
    weak var listener: AnyObject?
    var callback: (T)->Void
    
    init (listener:AnyObject, callback: (T)->Void) {
        self.listener = listener
        self.callback = callback
    }
}
