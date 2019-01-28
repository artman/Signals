//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

#if os(iOS) || os(tvOS)

import XCTest
import Signals

class UIControl_SignalsTests: XCTestCase {
    func test_actionObservation() {
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

        button.onTouchDown.subscribe(with: self) { _ in
            onTouchDownCount += 1
        }
        button.onTouchDownRepeat.subscribe(with: self) { _ in
            onTouchDownRepeatCount += 1
        }
        button.onTouchDragInside.subscribe(with: self) { _ in
            onTouchDragInsideCount += 1
        }
        button.onTouchDragOutside.subscribe(with: self) { _ in
            onTouchDragOutsideCount += 1
        }
        button.onTouchDragEnter.subscribe(with: self) { _ in
            onTouchDragEnterCount += 1
        }
        button.onTouchDragExit.subscribe(with: self) { _ in
            onTouchDragExitCount += 1
        }
        button.onTouchUpInside.subscribe(with: self) { _ in
            onTouchUpInsideCount += 1
        }
        button.onTouchUpOutside.subscribe(with: self) { _ in
            onTouchUpOutsideCount += 1
        }
        button.onTouchCancel.subscribe(with: self) { _ in
            onTouchCancelCount += 1
        }
        button.onValueChanged.subscribe(with: self) { _ in
            onValueChangedCount += 1
        }
        button.onEditingDidBegin.subscribe(with: self) { _ in
            onEditingDidBeginCount += 1
        }
        button.onEditingChanged.subscribe(with: self) { _ in
            onEditingChangedCount += 1
        }
        button.onEditingDidEnd.subscribe(with: self) { _ in
            onEditingDidEndCount += 1
        }
        button.onEditingDidEndOnExit.subscribe(with: self) { _ in
            onEditingDidEndOnExitCount += 1
        }

        let events: [UIControl.Event] = [.touchDown, .touchDownRepeat, .touchDragInside, .touchDragOutside,
                                         .touchDragEnter, .touchDragExit, .touchUpInside, .touchUpOutside,
                                         .touchCancel, .valueChanged, .editingDidBegin, .editingChanged,
                                         .editingDidEnd, .editingDidEndOnExit]

        for event in events {
            let actions = button.actions(forTarget: button, forControlEvent: event)
            for action in actions! {
                button.perform(Selector(action))
            }
        }

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

#endif
