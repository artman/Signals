//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

/// Extends UIControl with signals for all ui control events.
public extension UIControl {
    /// A signal that fires for each touch down control event.
    var onTouchDown: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchDown)
    }

    /// A signal that fires for each touch down repeat control event.
    var onTouchDownRepeat: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchDownRepeat)
    }

    /// A signal that fires for each touch drag inside control event.
    var onTouchDragInside: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchDragInside)
    }

    /// A signal that fires for each touch drag outside control event.
    var onTouchDragOutside: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchDragOutside)
    }

    /// A signal that fires for each touch drag enter control event.
    var onTouchDragEnter: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchDragEnter)
    }

    /// A signal that fires for each touch drag exit control event.
    var onTouchDragExit: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchDragExit)
    }

    /// A signal that fires for each touch up inside control event.
    var onTouchUpInside: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchUpInside)
    }

    /// A signal that fires for each touch up outside control event.
    var onTouchUpOutside: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchUpOutside)
    }

    /// A signal that fires for each touch cancel control event.
    var onTouchCancel: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.touchCancel)
    }

    /// A signal that fires for each value changed control event.
    var onValueChanged: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.valueChanged)
    }

    /// A signal that fires for each editing did begin control event.
    var onEditingDidBegin: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.editingDidBegin)
    }

    /// A signal that fires for each editing changed control event.
    var onEditingChanged: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.editingChanged)
    }

    /// A signal that fires for each editing did end control event.
    var onEditingDidEnd: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.editingDidEnd)
    }

    /// A signal that fires for each editing did end on exit control event.
    var onEditingDidEndOnExit: Signal<Void> {
        return getOrCreateSignalForUIControlEvent(.editingDidEndOnExit)
    }

    // MARK: - Private interface

    private struct AssociatedKeys {
        static var SignalDictionaryKey = "signals_signalKey"
    }

    private static let eventToKey: [UIControl.Event: NSString] = [
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

    private func getOrCreateSignalForUIControlEvent(_ event: UIControl.Event) -> Signal<Void> {
        guard let key = UIControl.eventToKey[event] else {
            assertionFailure("Event type is not handled")
            return Signal()
        }
        let dictionary = getOrCreateAssociatedObject(self, associativeKey: &AssociatedKeys.SignalDictionaryKey, defaultValue: NSMutableDictionary(), policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        if let signal = dictionary[key] as? Signal<Void> {
            return signal
        } else {
            let signal = Signal<Void>()
            dictionary[key] = signal
            self.addTarget(self, action: Selector("eventHandler\(key)"), for: event)
            return signal
        }
    }

    private func handleUIControlEvent(_ uiControlEvent: UIControl.Event) {
        getOrCreateSignalForUIControlEvent(uiControlEvent).fire()
    }

    @objc private dynamic func eventHandlerTouchDown() {
        handleUIControlEvent(.touchDown)
    }

    @objc private dynamic func eventHandlerTouchDownRepeat() {
        handleUIControlEvent(.touchDownRepeat)
    }

    @objc private dynamic func eventHandlerTouchDragInside() {
        handleUIControlEvent(.touchDragInside)
    }

    @objc private dynamic func eventHandlerTouchDragOutside() {
        handleUIControlEvent(.touchDragOutside)
    }

    @objc private dynamic func eventHandlerTouchDragEnter() {
        handleUIControlEvent(.touchDragEnter)
    }

    @objc private dynamic func eventHandlerTouchDragExit() {
        handleUIControlEvent(.touchDragExit)
    }

    @objc private dynamic func eventHandlerTouchUpInside() {
        handleUIControlEvent(.touchUpInside)
    }

    @objc private dynamic func eventHandlerTouchUpOutside() {
        handleUIControlEvent(.touchUpOutside)
    }

    @objc private dynamic func eventHandlerTouchCancel() {
        handleUIControlEvent(.touchCancel)
    }

    @objc private dynamic func eventHandlerValueChanged() {
        handleUIControlEvent(.valueChanged)
    }

    @objc private dynamic func eventHandlerEditingDidBegin() {
        handleUIControlEvent(.editingDidBegin)
    }

    @objc private dynamic func eventHandlerEditingChanged() {
        handleUIControlEvent(.editingChanged)
    }

    @objc private dynamic func eventHandlerEditingDidEnd() {
        handleUIControlEvent(.editingDidEnd)
    }

    @objc private dynamic func eventHandlerEditingDidEndOnExit() {
        handleUIControlEvent(.editingDidEndOnExit)
    }
}

extension UIControl.Event: Hashable {
    public var hashValue: Int {
        return Int(self.rawValue)
    }
}

#endif
