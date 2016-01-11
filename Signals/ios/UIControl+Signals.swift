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
        .TouchDown: "TouchDown",
        .TouchDownRepeat: "TouchDownRepeat",
        .TouchDragInside: "TouchDragInside",
        .TouchDragOutside: "TouchDragOutside",
        .TouchDragEnter: "TouchDragEnter",
        .TouchDragExit: "TouchDragExit",
        .TouchUpInside: "TouchUpInside",
        .TouchUpOutside: "TouchUpOutside",
        .TouchCancel: "TouchCancel",
        .ValueChanged: "ValueChanged",
        .EditingDidBegin: "EditingDidBegin",
        .EditingChanged: "EditingChanged",
        .EditingDidEnd: "EditingDidEnd",
        .EditingDidEndOnExit: "EditingDidEndOnExit"]
    
    // MARK - Public interface
    
    /// A signal that fires for each touch down control event.
    public var onTouchDown: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchDown);
    }
    
    /// A signal that fires for each touch down repeat control event.
    public var onTouchDownRepeat: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchDownRepeat);
    }
    
    /// A signal that fires for each touch drag inside control event.
    public var onTouchDragInside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchDragInside);
    }
    
    /// A signal that fires for each touch drag outside control event.
    public var onTouchDragOutside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchDragOutside);
    }
    
    /// A signal that fires for each touch drag enter control event.
    public var onTouchDragEnter: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchDragEnter);
    }
    
    /// A signal that fires for each touch drag exit control event.
    public var onTouchDragExit: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchDragExit);
    }
    
    /// A signal that fires for each touch up inside control event.
    public var onTouchUpInside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchUpInside);
    }
    
    /// A signal that fires for each touch up outside control event.
    public var onTouchUpOutside: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchUpOutside);
    }
    
    /// A signal that fires for each touch cancel control event.
    public var onTouchCancel: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.TouchCancel);
    }
    
    /// A signal that fires for each value changed control event.
    public var onValueChanged: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.ValueChanged);
    }
    
    /// A signal that fires for each editing did begin control event.
    public var onEditingDidBegin: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.EditingDidBegin);
    }
    
    /// A signal that fires for each editing changed control event.
    public var onEditingChanged: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.EditingChanged);
    }
    
    /// A signal that fires for each editing did end control event.
    public var onEditingDidEnd: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.EditingDidEnd);
    }
    
    /// A signal that fires for each editing did end on exit control event.
    public var onEditingDidEndOnExit: Signal<()> {
        return getOrCreateSignalForUIControlEvent(.EditingDidEndOnExit);
    }
    
    // MARK: - Internal interface
    
    private func getOrCreateSignalForUIControlEvent(event: UIControlEvents) -> Signal<()> {
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
            self.addTarget(self, action: Selector("eventHandler\(key)"), forControlEvents: event)
            return signal
        }
    }
    
    private func handleUIControlEvent(uiControlEvent: UIControlEvents) {
        getOrCreateSignalForUIControlEvent(uiControlEvent).fire()
    }
    
    // MARK: - Event handlers
    
    private dynamic func eventHandlerTouchDown() {
        handleUIControlEvent(.TouchDown)
    }
    
    private dynamic func eventHandlerTouchDownRepeat() {
        handleUIControlEvent(.TouchDownRepeat)
    }
    
    private dynamic func eventHandlerTouchDragInside() {
        handleUIControlEvent(.TouchDragInside)
    }
    
    private dynamic func eventHandlerTouchDragOutside() {
        handleUIControlEvent(.TouchDragOutside)
    }
    
    private dynamic func eventHandlerTouchDragEnter() {
        handleUIControlEvent(.TouchDragEnter)
    }
    
    private dynamic func eventHandlerTouchDragExit() {
        handleUIControlEvent(.TouchDragExit)
    }
    
    private dynamic func eventHandlerTouchUpInside() {
        handleUIControlEvent(.TouchUpInside)
    }
    
    private dynamic func eventHandlerTouchUpOutside() {
        handleUIControlEvent(.TouchUpOutside)
    }
    
    private dynamic func eventHandlerTouchCancel() {
        handleUIControlEvent(.TouchCancel)
    }
    
    private dynamic func eventHandlerValueChanged() {
        handleUIControlEvent(.ValueChanged)
    }
    
    private dynamic func eventHandlerEditingDidBegin() {
        handleUIControlEvent(.EditingDidBegin)
    }
    
    private dynamic func eventHandlerEditingChanged() {
        handleUIControlEvent(.EditingChanged)
    }
    
    private dynamic func eventHandlerEditingDidEnd() {
        handleUIControlEvent(.EditingDidEnd)
    }
    
    private dynamic func eventHandlerEditingDidEndOnExit() {
        handleUIControlEvent(.EditingDidEndOnExit)
    }
}

extension UIControlEvents: Hashable {
    public var hashValue: Int {
        return Int(self.rawValue)
    }
}
