//
//  SignalsTests.swift
//  SignalsTests
//
//  Created by Tuomas Artman on 16.10.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation
import XCTest

#if swift(>=3.0)
#else
    extension XCTestCase {
        @nonobjc func expectation(description descripton: String) -> XCTestExpectation {
            return self.expectation(withDescription: descripton)
        }
        
        @nonobjc func waitForExpectations(timeout: TimeInterval, handler: XCWaitCompletionHandler?) {
            self.waitForExpectations(withTimeout: timeout, handler: handler)
        }
    }
#endif

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
        let expectation = self.expectation(description: "queuedDispatch")

        emitter.onInt.listen(on: self, callback: { (argument) in
            XCTAssertEqual(argument, 1, "Last data catched")
            expectation.fulfill()
        }).queue(andDelayBy: 0.1)

        emitter.onInt.fire(1);

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testDispatchQueueing() {
        let expectation = self.expectation(description: "queuedDispatch")
 
        emitter.onInt.listen(on: self, callback: { (argument) in
            XCTAssertEqual(argument, 3, "Last data catched")
            expectation.fulfill()
        }).queue(andDelayBy: 0.1)
        
        emitter.onInt.fire(1);
        emitter.onInt.fire(2);
        emitter.onInt.fire(3);
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testNoQueueTimeFiring() {
        let expectation = self.expectation(description: "queuedDispatch")

        emitter.onInt.listen(on: self, callback: { (argument) in
            XCTAssertEqual(argument, 3, "Last data catched")
            expectation.fulfill()
        }).queue(andDelayBy: 0.0)
        
        emitter.onInt.fire(1);
        emitter.onInt.fire(2);
        emitter.onInt.fire(3);
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testConditionalListening() {
        let expectation = self.expectation(description: "queuedDispatch")
        
        emitter.onIntAndString.listen(on: self, callback: { (argument1, argument2) -> Void in
            XCTAssertEqual(argument1, 2, "argument1 catched")
            XCTAssertEqual(argument2, "test2", "argument2 catched")
            expectation.fulfill()
            
        }).queue(andDelayBy: 0.01).filter { $0 == 2 && $1 == "test2" }
        
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test2"))
        emitter.onIntAndString.fire((intArgument:2, stringArgument:"test2"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test3"))
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCancellingListeners() {
        let expectation = self.expectation(description: "queuedDispatch")
        
        let listener = emitter.onIntAndString.listen(on: self, callback: { (argument1, argument2) -> Void in
            XCTFail("Listener should have been canceled")
        }).queue(andDelayBy: 0.01)
        
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        listener.cancel()
        
        let block = {
            // Cancelled listener didn't dispatch
            expectation.fulfill()
        }
        
        #if swift(>=3.0)
            DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64(0.05 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
        #else
        DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64(0.05 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
        #endif
            
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testListeningNoData() {
        let expectation = self.expectation(description: "queuedDispatch")
        var dispatchCount = 0

        emitter.onNoParams.listen(on: self, callback: { () -> Void in
            dispatchCount += 1
            XCTAssertEqual(dispatchCount, 1, "Dispatched only once")
            expectation.fulfill()
        }).queue(andDelayBy: 0.01)
        
        emitter.onNoParams.fire()
        emitter.onNoParams.fire()
        emitter.onNoParams.fire()
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testListenerProperty() {
        var listener1: NSObject? = NSObject()
        var listener2: NSObject? = NSObject()
        
        emitter.onInt.listen(on: listener1!) { _ = $0 }
        emitter.onInt.listen(on: listener2!) { _ = $0 }
        
        XCTAssertEqual(emitter.onInt.listeners.count, 2, "Should have two listener")
        
        listener1 = nil
        XCTAssertEqual(emitter.onInt.listeners.count, 1, "Should have one listener")
        
        listener2 = nil
        XCTAssertEqual(emitter.onInt.listeners.count, 0, "Should have zero listener")
    }

    func testListeningOnDispatchQueue() {
        let firstQueueLabel = "com.signals.queue.first";
        let secondQueueLabel = "com.signals.queue.second";
        #if swift(>=3.0)
            let firstQueue = DispatchQueue(label: firstQueueLabel)
            let secondQueue = DispatchQueue(label: secondQueueLabel, attributes: DispatchQueue.Attributes.concurrent)
        #else
            let firstQueue = DispatchQueue(label: firstQueueLabel, attributes: [])
            let secondQueue = DispatchQueue(label: secondQueueLabel, attributes: DispatchQueue.Attributes.concurrent)
        #endif

        let firstListener = NSObject()
        let secondListener = NSObject()

        let firstExpectation = expectation(description: "firstDispatchOnQueue")
        emitter.onInt.listen(on: firstListener, callback: { (argument) in
            #if swift(>=3.0)
                let currentQueueLabel = String(validatingUTF8: __dispatch_queue_get_label(nil))
            #else
                let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
            #endif
            XCTAssertTrue(firstQueueLabel == currentQueueLabel)
            firstExpectation.fulfill()
        }).dispatch(onQueue: firstQueue)
        let secondExpectation = expectation(description: "secondDispatchOnQueue")
        emitter.onInt.listen(on: secondListener, callback: { (argument) in
            #if swift(>=3.0)
                let currentQueueLabel = String(validatingUTF8: __dispatch_queue_get_label(nil))
            #else
                let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
            #endif
            XCTAssertTrue(secondQueueLabel == currentQueueLabel)
            secondExpectation.fulfill()
        }).dispatch(onQueue: secondQueue)

        emitter.onInt.fire(10)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUsesCurrentQueueByDefault() {
        let queueLabel = "com.signals.queue";
        #if swift(>=3.0)
            let queue = DispatchQueue(label: queueLabel, attributes: DispatchQueue.Attributes.concurrent)
        #else
            let queue = DispatchQueue(label: queueLabel, attributes: DispatchQueue.Attributes.concurrent)
        #endif

        let listener = NSObject()
        let expectation = self.expectation(description: "receivedCallbackOnQueue")

        emitter.onInt.listen(on: listener, callback: { (argument) in
            #if swift(>=3.0)
                let currentQueueLabel = String(validatingUTF8: __dispatch_queue_get_label(nil))
            #else
                let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))
            #endif
            XCTAssertTrue(queueLabel == currentQueueLabel)
            expectation.fulfill()
        })

        #if swift(>=3.0)
            queue.async {
                self.emitter.onInt.fire(10)
            }
        #else
            queue.async {
                self.emitter.onInt.fire(10)
            }
        #endif

        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
