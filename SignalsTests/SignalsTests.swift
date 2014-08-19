//
//  SignalsTests.swift
//  SignalsTests
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import UIKit
import XCTest

class SignalsTests: XCTestCase {
    
    var emitter:SignalEmitter = SignalEmitter();
    
    override func setUp() {
        super.setUp()
        emitter = SignalEmitter()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testBasicFiring() {
        var intSignalResult = 0
        var stringSignalResult = ""
        
        emitter.onInt.listen(self, callback: { (argument) in
            intSignalResult = argument;
        })
        emitter.onString.listen(self, callback: { (argument) in
            stringSignalResult = argument;
        })
        
        emitter.onInt.fire(1);
        emitter.onString.fire("test");
        
        XCTAssertEqual(intSignalResult, 1, "IntSignal catched")
        XCTAssertEqual(stringSignalResult, "test", "StringSignal catched")
    }

    func testMultiArgumentFiring() {
        var intSignalResult = 0
        var stringSignalResult = ""
        
        emitter.onIntAndString.listen(self, callback: { (argument1, argument2) -> Void in
            intSignalResult = argument1
            stringSignalResult = argument2
        })
        
        emitter.onIntAndString.fire(1, "test")
        
        XCTAssertEqual(intSignalResult, 1, "argument1 catched")
        XCTAssertEqual(stringSignalResult, "test", "argument2 catched")
    }
    
    func testMultiFiring() {
        // This is an example of a functional test case.
        var dispatchCount = 0
        var lastArgument = 0
        
        emitter.onInt.listen(self, callback: { (argument) in
            dispatchCount++
            lastArgument = argument
        })
        
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)

        
        XCTAssertEqual(dispatchCount, 2, "Dispatched two times")
        XCTAssertEqual(lastArgument, 2, "Last argument catched with value 2")
    }
    
    func testMultiListenersOneObject() {
        var dispatchCount = 0
        var lastArgument = 0
        
        emitter.onInt.listen(self, callback: { (argument) in
            dispatchCount++
            lastArgument = argument
        })
        emitter.onInt.listen(self, callback: { (argument) in
            dispatchCount++
            lastArgument = argument + 1
        })
        
        emitter.onInt.fire(1)

        XCTAssertEqual(dispatchCount, 2, "Dispatched two times")
        XCTAssertEqual(lastArgument, 2, "Last argument catched with value 2")
    }
    
    func testMultiListenersManyObjects() {
        var testListeners = [
            TestListener(),
            TestListener(),
            TestListener()
        ]
        
        for listener in testListeners {
            listener.listenTo(emitter)
        }
        
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)
        
        for listener in testListeners {
            XCTAssertEqual(listener.dispatchCount, 2, "Dispatched two times")
            XCTAssertEqual(listener.lastArgument, 2, "Last argument catched with value 2")
        }
    }
    
    func testRemovingListeners() {
        var dispatchCount: Int = 0
        
        emitter.onInt.listen(self, callback: { (argument) in
            dispatchCount += 1
        })
        emitter.onInt.listen(self, callback: { (argument) in
            dispatchCount += 1
        })
        
        emitter.onInt.removeListener(self)
        emitter.onInt.fire(1)
        
        XCTAssertEqual(dispatchCount, 0, "Shouldn't have catched signal fire")
    }
    
    func testRemovingAllListeners() {
        var dispatchCount: Int = 0
        
        emitter.onInt.listen(self, callback: { (argument) in
            dispatchCount += 1
        })
        emitter.onInt.listen(self, callback: { (argument) in
            dispatchCount += 1
        })
        
        emitter.onInt.removeAllListeners()
        emitter.onInt.fire(1)
        
        XCTAssertEqual(dispatchCount, 0, "Shouldn't have catched signal fire")
    }
    
    func testAutoRemoveWeakListeners() {
        var dispatchCount: Int = 0

        var listener: TestListener? = TestListener()
        listener!.listenTo(emitter)
        listener = nil
        
        emitter.onInt.fire(1)

        XCTAssertEqual(emitter.onInt.listeners.count, 0, "Weak listener should have been collected")
    }
}
