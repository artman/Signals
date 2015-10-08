//
//  SignalsTests.swift
//  SignalsTests
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import UIKit
import XCTest
@testable import Signals

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
    
    func testNoArgumentFiring() {
        var signalCount = 0
        
        emitter.onNoParams.listen(self, callback: { () -> Void in
            signalCount += 1;
        })
        
        emitter.onNoParams.fire();
        
        XCTAssertEqual(signalCount, 1, "Signal catched")
    }

    func testMultiArgumentFiring() {
        var intSignalResult = 0
        var stringSignalResult = ""
        
        emitter.onIntAndString.listen(self, callback: { (argument1, argument2) -> Void in
            intSignalResult = argument1
            stringSignalResult = argument2
        })
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(intSignalResult, 1, "argument1 catched")
        XCTAssertEqual(stringSignalResult, "test", "argument2 catched")
    }
    
    func testMultiFiring() {
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
        let testListeners = [
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
    
    func testListeningOnce() {
        let listener1 = TestListener()
        let listener2 = TestListener()
        let listener3 = TestListener()
        
        listener1.listenTo(emitter)
        listener2.listenOnceTo(emitter)
        listener3.listenPastTo(emitter)
        
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)
        
        XCTAssertEqual(listener1.dispatchCount, 2, "Dispatched two times")
        XCTAssertEqual(listener2.dispatchCount, 1, "Dispatched one time")
        XCTAssertEqual(listener3.dispatchCount, 2, "Dispatched two times")
    }
    
    func testListeningPastOnceAlreadyFired() {
        let listener = TestListener()

        emitter.onInt.fire(1)
        emitter.onInt.fire(2)
        listener.listenPastOnceTo(emitter)
        emitter.onInt.fire(3)
        emitter.onInt.fire(4)

        XCTAssertEqual(listener.dispatchCount, 1, "Dispatched once")
        XCTAssertEqual(listener.lastArgument, 2, "Remembered the most recent data")
    }

    func testListeningPastOnceNotFiredYet() {
        let listener = TestListener()

        listener.listenPastOnceTo(emitter)
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)

        XCTAssertEqual(listener.dispatchCount, 1, "Dispatched once")
        XCTAssertEqual(listener.lastArgument, 1, "Remembered only the relevant data")
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
        var listener: TestListener? = TestListener()
        listener!.listenTo(emitter)
        listener = nil
        
        emitter.onInt.fire(1)

        XCTAssertEqual(emitter.onInt.listeners.count, 0, "Weak listener should have been collected")
    }
    
    func testPostListening() {
        var intSignalResult = 0
        var stringSignalResult = ""
        var dispatchCount = 0
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        emitter.onIntAndString.listenPast(self, callback: { (argument1, argument2) -> Void in
            intSignalResult = argument1
            stringSignalResult = argument2
            dispatchCount += 1
        })

        XCTAssertEqual(intSignalResult, 1, "argument1 catched")
        XCTAssertEqual(stringSignalResult, "test", "argument2 catched")
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 2, "Second fire catched")
    }
    
    func testConditionalListening() {
        var intSignalResult = 0
        var stringSignalResult = ""
        var dispatchCount = 0
        
        emitter.onIntAndString.listen(self, callback: { (argument1, argument2) -> Void in
            intSignalResult = argument1
            stringSignalResult = argument2
            dispatchCount += 1
        }).filter { (intArgument, stringArgument) -> Bool in
            return intArgument == 2 && stringArgument == "test2"
        }
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test2")
        emitter.onIntAndString => (intArgument:2, stringArgument:"test2")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test3")
        
        XCTAssertEqual(dispatchCount, 1, "Filtered fires")
        XCTAssertEqual(intSignalResult, 2, "argument1 catched")
        XCTAssertEqual(stringSignalResult, "test2", "argument2 catched")
    }
    
    func testConditionalListeningOnce() {
        var intSignalResult = 0
        var stringSignalResult = ""
        var dispatchCount = 0
        
        emitter.onIntAndString.listenOnce(self, callback: { (argument1, argument2) -> Void in
            intSignalResult = argument1
            stringSignalResult = argument2
            dispatchCount += 1
        }).filter { $0 == 2 && $1 == "test2" }
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:2, stringArgument:"test2")
        emitter.onIntAndString => (intArgument:2, stringArgument:"test2")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test3")
        
        XCTAssertEqual(dispatchCount, 1, "Filtered fires")
        XCTAssertEqual(intSignalResult, 2, "argument1 catched")
        XCTAssertEqual(stringSignalResult, "test2", "argument2 catched")
    }
    
    func testCancellingListeners() {
        var dispatchCount = 0
        
        let listener = emitter.onIntAndString.listen(self, callback: { (argument1, argument2) -> Void in
            dispatchCount += 1
        })
     
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        listener.cancel()
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")

        XCTAssertEqual(dispatchCount, 1, "Filtered fires")
    }
    
    func testPostListeningNoData() {
        var dispatchCount = 0
        
        emitter.onNoParams.fire()
        
        emitter.onNoParams.listenPast(self, callback: { () -> Void in
            dispatchCount += 1
        })
        
        XCTAssertEqual(dispatchCount, 1, "Catched signal fire")
    }
    
    func testRemoveOwnListenerWhileFiring() {
        var dispatchCount = 0
 
        emitter.onIntAndString.listenOnce(self) { (intArgument, stringArgument) -> Void in
            self.emitter.onIntAndString.removeListener(self)
            dispatchCount += 1
        }
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 1, "Should have dispatched correct number of times")
    }
    
    func testRemovePreviousListenersWhileFiring() {
        var dispatchCount = 0
        
        let listener1 = NSObject()
        let listener2 = NSObject()
        let listener3 = NSObject()
        
        emitter.onIntAndString.listen(listener1) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        emitter.onIntAndString.listen(listener2) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.removeListener(listener1)
        }
        emitter.onIntAndString.listen(listener3) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.removeListener(listener2)
        }
        self.emitter.onIntAndString.removeListener(listener2)
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")

        XCTAssertEqual(dispatchCount, 3+1, "Should have dispatched correct number of times")
    }
    
    func testRemoveUpcomingListenersWhileFiring() {
        var dispatchCount = 0
        
        let listener1 = NSObject()
        let listener2 = NSObject()
        let listener3 = NSObject()
        
        emitter.onIntAndString.listen(listener1) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.removeListener(listener2)
        }
        emitter.onIntAndString.listen(listener2) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        emitter.onIntAndString.listen(listener3) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        self.emitter.onIntAndString.removeListener(listener2)
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 2+2, "Should have dispatched correct number of times")
    }
    
    func testRemoveAllListenersWhileFiring() {
        var dispatchCount = 0
        
        let listener1 = NSObject()
        let listener2 = NSObject()
        let listener3 = NSObject()
        
        emitter.onIntAndString.listen(listener1) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.removeAllListeners()
        }
        emitter.onIntAndString.listen(listener2) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        emitter.onIntAndString.listen(listener3) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        self.emitter.onIntAndString.removeListener(listener2)
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 1+1, "Should have dispatched correct number of times")
    }
    
    func testPerformanceFiring() {
        self.measureBlock() {
            var dispatchCount = 0
            for _ in 0..<10 {
                self.emitter.onIntAndString.listen(self) { (argument1, argument2) -> Void in
                    dispatchCount += 1
                }
            }
            for _ in 0..<110 {
                self.emitter.onIntAndString => (intArgument:1, stringArgument:"test")
            }
        }
    }
}
