//
//  UIBarButtonItem+Signals.swift
//  Signals iOS
//
//  Created by Linus Unnebäck on 2018-03-09.
//  Copyright © 2018 Tuomas Artman. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

/// Extends UIBarButtonItem with signal for the action.
public extension UIBarButtonItem {
    /// A signal that fires for each action event.
    var onAction: Signal<Void> {
        return getOrCreateSignal()
    }

    // MARK: - Private interface

    private struct AssociatedKeys {
        static var SignalDictionaryKey = "signals_signalKey"
    }

    private func getOrCreateSignal() -> Signal<Void> {
        let key = "Action"
        let dictionary = getOrCreateAssociatedObject(self, associativeKey: &AssociatedKeys.SignalDictionaryKey, defaultValue: NSMutableDictionary(), policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        if let signal = dictionary[key] as? Signal<Void> {
            return signal
        } else {
            let signal = Signal<Void>()
            dictionary[key] = signal
            self.target = self
            self.action = #selector(eventHandlerAction)
            return signal
        }
    }

    @objc private dynamic func eventHandlerAction() {
        getOrCreateSignal().fire()
    }
}

#endif
