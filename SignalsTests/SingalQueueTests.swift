//
//  SignalsTests.swift
//  SignalsTests
//
//  Created by Tuomas Artman on 16.10.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import UIKit
import XCTest

class SignalQueueTests: XCTestCase {
    
    var emitter:SignalEmitter = SignalEmitter();
    
    override func setUp() {
        super.setUp()
        emitter = SignalEmitter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBasicFiring() {
        let expectation = expectationWithDescription("queuedDispatch")

        emitter.onInt.listen(self, callback: { (argument) in
            XCTAssertEqual(argument, 1, "Last data catched")
            expectation.fulfill()
        }).queueAndDelayBy(0.1)

        emitter.onInt.fire(1);

        waitForExpectationsWithTimeout(0.15, handler: nil)
    }
    
    func testDispatchQueueing() {
        let expectation = expectationWithDescription("queuedDispatch")
 
        emitter.onInt.listen(self, callback: { (argument) in
            XCTAssertEqual(argument, 3, "Last data catched")
            expectation.fulfill()
        }).queueAndDelayBy(0.1)
        
        emitter.onInt.fire(1);
        emitter.onInt.fire(2);
        emitter.onInt.fire(3);
        
        waitForExpectationsWithTimeout(0.15, handler: nil)
    }
    
    func testNoQueueTimeFiring() {
        let expectation = expectationWithDescription("queuedDispatch")

        emitter.onInt.listen(self, callback: { (argument) in
            XCTAssertEqual(argument, 3, "Last data catched")
            expectation.fulfill()
        }).queueAndDelayBy(0.0)
        
        emitter.onInt.fire(1);
        emitter.onInt.fire(2);
        emitter.onInt.fire(3);
        
        waitForExpectationsWithTimeout(0.05, handler: nil)
    }
    
    func testConditionalListening() {
        let expectation = expectationWithDescription("queuedDispatch")
        
        emitter.onIntAndString.listen(self, callback: { (argument1, argument2) -> Void in
            XCTAssertEqual(argument1, 2, "argument1 catched")
            XCTAssertEqual(argument2, "test2", "argument2 catched")
            expectation.fulfill()
            
        }).queueAndDelayBy(0.01).filter { $0 == 2 && $1 == "test2" }
        
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test2"))
        emitter.onIntAndString.fire((intArgument:2, stringArgument:"test2"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test3"))
        
        waitForExpectationsWithTimeout(0.02, handler: nil)
    }
    
    func testCancellingListeners() {
        let expectation = expectationWithDescription("queuedDispatch")
        
        let listener = emitter.onIntAndString.listen(self, callback: { (argument1, argument2) -> Void in
            XCTFail("Listener should have been canceled")
        }).queueAndDelayBy(0.01)
        
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        listener.cancel()
        
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            // Cancelled listener didn't dispatch
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    
    func testListeningNoData() {
        let expectation = expectationWithDescription("queuedDispatch")
        var dispatchCount = 0

        emitter.onNoParams.listen(self, callback: { () -> Void in
            dispatchCount++
            XCTAssertEqual(dispatchCount, 1, "Dispatched only once")
            expectation.fulfill()
        }).queueAndDelayBy(0.01)
        
        emitter.onNoParams.fire()
        emitter.onNoParams.fire()
        emitter.onNoParams.fire()
        
        waitForExpectationsWithTimeout(0.05, handler: nil)
    }
    
    func testListenerProperty() {
        var listener1: NSObject? = NSObject()
        var listener2: NSObject? = NSObject()
        
        emitter.onInt.listen(listener1!) { $0 }
        emitter.onInt.listen(listener2!) { $0 }
        
        XCTAssertEqual(emitter.onInt.listeners.count, 2, "Should have two listener")
        
        listener1 = nil
        XCTAssertEqual(emitter.onInt.listeners.count, 1, "Should have one listener")
        
        listener2 = nil
        XCTAssertEqual(emitter.onInt.listeners.count, 0, "Should have zero listener")
    }

    func testListeningOnDispatchQueue() {
        let firstQueueLabel = "com.signals.queue.first";
        let firstQueue = dispatch_queue_create(firstQueueLabel, DISPATCH_QUEUE_SERIAL)
        let secondQueueLabel = "com.signals.queue.second";
        let secondQueue = dispatch_queue_create(secondQueueLabel, DISPATCH_QUEUE_CONCURRENT)

        var dispatchCount = 0
        let firstListener = NSObject()
        let secondListener = NSObject()

        let firstExpectation = expectationWithDescription("firstDispatchOnQueue")
        emitter.onInt.listen(firstListener, callback: { (argument) in
            let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
            XCTAssertTrue(firstQueueLabel == currentQueueLabel)
            dispatchCount++
            firstExpectation.fulfill()
        }).dispatchOnQueue(firstQueue)
        let secondExpectation = expectationWithDescription("secondDispatchOnQueue")
        emitter.onInt.listen(secondListener, callback: { (argument) in
            let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
            XCTAssertTrue(secondQueueLabel == currentQueueLabel)
            dispatchCount++
            secondExpectation.fulfill()
        }).dispatchOnQueue(secondQueue)

        emitter.onInt.fire(10)

        waitForExpectationsWithTimeout(0.05, handler: nil)
        XCTAssertEqual(dispatchCount, 2, "Should be dispatched twice!")
    }

    func testUsesCurrentQueueByDefault() {
        let queueLabel = "com.signals.queue";
        let queue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_CONCURRENT)

        let listener = NSObject()
        let expectation = expectationWithDescription("receivedCallbackOnQueue")

        emitter.onInt.listen(listener, callback: { (argument) in
            let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
            XCTAssertTrue(queueLabel == currentQueueLabel)
            expectation.fulfill()
        })

        dispatch_async(queue) {
            self.emitter.onInt.fire(10)
        }

        waitForExpectationsWithTimeout(0.05, handler: nil)
    }

}
