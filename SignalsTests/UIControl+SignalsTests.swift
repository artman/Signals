//
//  UIControl+SignalsTests.swift
//  Signals
//
//  Created by Tuomas Artman on 1.1.2016.
//  Copyright © 2016 Tuomas Artman. All rights reserved.
//

import XCTest
import Signals

class UIControl_SignalsTests: XCTestCase {
    func testActionObservation() {
        let button = UIButton()

        var onTouchDownCount = 0
        var onTouchDownRepeatCount = 0
        var onTouchDragInsideCount = 0
        var onTouchDragOutsideCount = 0
        var onTouchDragEnterCount = 0
        var onTouchDragExitCount = 0
        var onTouchUpInsideCount = 0
        var onTouchUpOutsideCount = 0
        var onTouchCancelCount = 0
        var onValueChangedCount = 0
        var onEditingDidBeginCount = 0
        var onEditingChangedCount = 0
        var onEditingDidEndCount = 0
        var onEditingDidEndOnExitCount = 0

        button.onTouchDown.listen(self) {
            onTouchDownCount += 1
        }
        button.onTouchDownRepeat.listen(self) {
            onTouchDownRepeatCount += 1
        }
        button.onTouchDragInside.listen(self) {
            onTouchDragInsideCount += 1
        }
        button.onTouchDragOutside.listen(self) {
            onTouchDragOutsideCount += 1
        }
        button.onTouchDragEnter.listen(self) {
            onTouchDragEnterCount += 1
        }
        button.onTouchDragExit.listen(self) {
            onTouchDragExitCount += 1
        }
        button.onTouchUpInside.listen(self) {
            onTouchUpInsideCount += 1
        }
        button.onTouchUpOutside.listen(self) {
            onTouchUpOutsideCount += 1
        }
        button.onTouchCancel.listen(self) {
            onTouchCancelCount += 1
        }
        button.onValueChanged.listen(self) {
            onValueChangedCount += 1
        }
        button.onEditingDidBegin.listen(self) {
            onEditingDidBeginCount += 1
        }
        button.onEditingChanged.listen(self) {
            onEditingChangedCount += 1
        }
        button.onEditingDidEnd.listen(self) {
            onEditingDidEndCount += 1
        }
        button.onEditingDidEndOnExit.listen(self) {
            onEditingDidEndOnExitCount += 1
        }
        
        #if swift(>=3.0)
            let events: [UIControlEvents] = [.touchDown, .touchDownRepeat, .touchDragInside, .touchDragOutside, .touchDragEnter,
                .touchDragExit, .touchUpInside, .touchUpOutside, .touchCancel, .valueChanged, .editingDidBegin, .editingChanged,
                .editingDidEnd, .editingDidEndOnExit];
            
            for event in events {
                let actions = button.actions(forTarget: button, forControlEvent: event);
                for action in actions! {
                    button.perform(Selector(action))
                }
            }
        #else
            let events: [UIControlEvents] = [.TouchDown, .TouchDownRepeat, .TouchDragInside, .TouchDragOutside, .TouchDragEnter,
                                             .TouchDragExit, .TouchUpInside, .TouchUpOutside, .TouchCancel, .ValueChanged, .EditingDidBegin, .EditingChanged,
                                             .EditingDidEnd, .EditingDidEndOnExit];
            
            for event in events {
                let actions = button.actionsForTarget(button, forControlEvent: event);
                for action in actions! {
                    button.performSelector(Selector(action))
                }
            }
        #endif
            
        
        XCTAssertEqual(onTouchDownCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchDownRepeatCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchDragInsideCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchDragOutsideCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchDragEnterCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchDragExitCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchUpInsideCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchUpOutsideCount, 1, "Should have triggered once")
        XCTAssertEqual(onTouchCancelCount, 1, "Should have triggered once")
        XCTAssertEqual(onValueChangedCount, 1, "Should have triggered once")
        XCTAssertEqual(onEditingDidBeginCount, 1, "Should have triggered once")
        XCTAssertEqual(onEditingChangedCount, 1, "Should have triggered once")
        XCTAssertEqual(onEditingDidEndCount, 1, "Should have triggered once")
        XCTAssertEqual(onEditingDidEndOnExitCount, 1, "Should have triggered once")
    }
}
