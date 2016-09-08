//
//  UIControl+Signals.swift
//  Signals
//
//  Created by Tuomas Artman on 12/23/2015.
//  Copyright © 2015 Tuomas Artman. All rights reserved.
//


import UIKit

/// Extends UIControl with signals for all ui control events.

public extension UIControl {
    private struct AssociatedKeys {
        static var SignalDictionaryKey = "signals_signalKey"
    }
    
    static let eventToKey: [UIControlEvents: NSString] = [
        .touchDown: "TouchDown",
        .touchDownRepeat: "TouchDownRepeat",
        .touchDragInside: "TouchDragInside",
        .touchDragOutside: "TouchDragOutside",
        .touchDragEnter: "TouchDragEnter",
        .touchDragExit: "TouchDragExit",
        .touchUpInside: "TouchUpInside",
        .touchUpOutside: "TouchUpOutside",
        .touchCancel: "TouchCancel",
        .valueChanged: "ValueChanged",
        .editingDidBegin: "EditingDidBegin",
        .editingChanged: "EditingChanged",
        .editingDidEnd: "EditingDidEnd",
        .editingDidEndOnExit: "EditingDidEndOnExit"]
    
    // MARK - Public interface
    
    /// A signal that fires for each touch down control event.
    public var onTouchDown: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchDown);
    }
    
    /// A signal that fires for each touch down repeat control event.
    public var onTouchDownRepeat: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchDownRepeat);
    }
    
    /// A signal that fires for each touch drag inside control event.
    public var onTouchDragInside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchDragInside);
    }
    
    /// A signal that fires for each touch drag outside control event.
    public var onTouchDragOutside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchDragOutside);
    }
    
    /// A signal that fires for each touch drag enter control event.
    public var onTouchDragEnter: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchDragEnter);
    }
    
    /// A signal that fires for each touch drag exit control event.
    public var onTouchDragExit: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchDragExit);
    }
    
    /// A signal that fires for each touch up inside control event.
    public var onTouchUpInside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchUpInside);
    }
    
    /// A signal that fires for each touch up outside control event.
    public var onTouchUpOutside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchUpOutside);
    }
    
    /// A signal that fires for each touch cancel control event.
    public var onTouchCancel: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.touchCancel);
    }
    
    /// A signal that fires for each value changed control event.
    public var onValueChanged: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.valueChanged);
    }
    
    /// A signal that fires for each editing did begin control event.
    public var onEditingDidBegin: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.editingDidBegin);
    }
    
    /// A signal that fires for each editing changed control event.
    public var onEditingChanged: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.editingChanged);
    }
    
    /// A signal that fires for each editing did end control event.
    public var onEditingDidEnd: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.editingDidEnd);
    }
    
    /// A signal that fires for each editing did end on exit control event.
    public var onEditingDidEndOnExit: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.editingDidEndOnExit);
    }
    
    // MARK: - Internal interface
    
    private func getOrCreateSignalForUIControlEvent(_ event: UIControlEvents) -> Signal<()> {
        guard let key = UIControl.eventToKey[event] else {
            assertionFailure("Event type is not handled")
            return Signal()
        }
        let dictionary = getOrCreateAssociatedObject(self, associativeKey: &AssociatedKeys.SignalDictionaryKey, defaultValue: NSMutableDictionary(), policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        if let signal = dictionary[key] as? Signal<()> {
            return signal
        } else {
            let signal = Signal<()>()
            dictionary[key] = signal
            self.addTarget(self, action: Selector("eventHandler\(key)"), for: event)
            return signal
        }
    }
    
    private func handleUIControlEvent(_ uiControlEvent: UIControlEvents) {
        getOrCreateSignalForUIControlEvent(uiControlEvent).fire()
    }
    
    // MARK: - Event handlers
    
    private dynamic func eventHandlerTouchDown() {
        handleUIControlEvent(.touchDown)
    }
    
    private dynamic func eventHandlerTouchDownRepeat() {
        handleUIControlEvent(.touchDownRepeat)
    }
    
    private dynamic func eventHandlerTouchDragInside() {
        handleUIControlEvent(.touchDragInside)
    }
    
    private dynamic func eventHandlerTouchDragOutside() {
        handleUIControlEvent(.touchDragOutside)
    }
    
    private dynamic func eventHandlerTouchDragEnter() {
        handleUIControlEvent(.touchDragEnter)
    }
    
    private dynamic func eventHandlerTouchDragExit() {
        handleUIControlEvent(.touchDragExit)
    }
    
    private dynamic func eventHandlerTouchUpInside() {
        handleUIControlEvent(.touchUpInside)
    }
    
    private dynamic func eventHandlerTouchUpOutside() {
        handleUIControlEvent(.touchUpOutside)
    }
    
    private dynamic func eventHandlerTouchCancel() {
        handleUIControlEvent(.touchCancel)
    }
    
    private dynamic func eventHandlerValueChanged() {
        handleUIControlEvent(.valueChanged)
    }
    
    private dynamic func eventHandlerEditingDidBegin() {
        handleUIControlEvent(.editingDidBegin)
    }
    
    private dynamic func eventHandlerEditingChanged() {
        handleUIControlEvent(.editingChanged)
    }
    
    private dynamic func eventHandlerEditingDidEnd() {
        handleUIControlEvent(.editingDidEnd)
    }
    
    private dynamic func eventHandlerEditingDidEndOnExit() {
        handleUIControlEvent(.editingDidEndOnExit)
    }
}

extension UIControlEvents: Hashable {
    public var hashValue: Int {
        return Int(self.rawValue)
    }
}
