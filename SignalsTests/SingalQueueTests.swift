//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

import Foundation
import XCTest
@testable import Signals
#if os(Linux)
import Dispatch
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

        emitter.onInt.subscribe(with: self, callback: { (argument) in
            XCTAssertEqual(argument, 1, "Last data catched")
            expectation.fulfill()
        }).sample(every: 0.1)

        emitter.onInt.fire(1);

        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testDispatchQueueing() {
        let expectation = self.expectation(description: "queuedDispatch")
 
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            XCTAssertEqual(argument, 3, "Last data catched")
            expectation.fulfill()
        }).sample(every: 0.1)
        
        emitter.onInt.fire(1);
        emitter.onInt.fire(2);
        emitter.onInt.fire(3);
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testNoQueueTimeFiring() {
        let expectation = self.expectation(description: "queuedDispatch")

        emitter.onInt.subscribe(with: self, callback: { (argument) in
            XCTAssertEqual(argument, 3, "Last data catched")
            expectation.fulfill()
        }).sample(every: 0.0)
        
        emitter.onInt.fire(1);
        emitter.onInt.fire(2);
        emitter.onInt.fire(3);
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testConditionalListening() {
        let expectation = self.expectation(description: "queuedDispatch")
        
        emitter.onIntAndString.subscribe(with: self, callback: { (argument1, argument2) -> Void in
            XCTAssertEqual(argument1, 2, "argument1 catched")
            XCTAssertEqual(argument2, "test2", "argument2 catched")
            expectation.fulfill()
            
        }).sample(every: 0.01).filter { $0 == 2 && $1 == "test2" }
        
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test2"))
        emitter.onIntAndString.fire((intArgument:2, stringArgument:"test2"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test3"))
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testCancellingListeners() {
        let expectation = self.expectation(description: "queuedDispatch")
        
        let observer = emitter.onIntAndString.subscribe(with: self, callback: { (argument1, argument2) -> Void in
            XCTFail("Listener should have been canceled")
        }).sample(every: 0.01)
        
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        emitter.onIntAndString.fire((intArgument:1, stringArgument:"test"))
        observer.cancel()
        
        let block = {
            // Cancelled observer didn't dispatch
            expectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + .milliseconds(50), execute: block)
            
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testListeningNoData() {
        let expectation = self.expectation(description: "queuedDispatch")
        var dispatchCount = 0

        emitter.onNoParams.subscribe(with: self, callback: { () -> Void in
            dispatchCount += 1
            XCTAssertEqual(dispatchCount, 1, "Dispatched only once")
            expectation.fulfill()
        }).sample(every: 0.01)
        
        emitter.onNoParams.fire(())
        emitter.onNoParams.fire(())
        emitter.onNoParams.fire(())
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testListenerProperty() {
        var observer1: NSObject? = NSObject()
        var observer2: NSObject? = NSObject()
        
        emitter.onInt.subscribe(with: observer1!) { _ = $0 }
        emitter.onInt.subscribe(with: observer2!) { _ = $0 }
        
        XCTAssertEqual(emitter.onInt.observers.count, 2, "Should have two observer")
        
        observer1 = nil
        XCTAssertEqual(emitter.onInt.observers.count, 1, "Should have one observer")
        
        observer2 = nil
        XCTAssertEqual(emitter.onInt.observers.count, 0, "Should have zero observer")
    }

    func testListeningOnDispatchQueue() {
        let firstQueueLabel = "com.signals.queue.first";
        let secondQueueLabel = "com.signals.queue.second";

        let labelKey = DispatchSpecificKey<String>()
        let firstQueue = DispatchQueue(label: firstQueueLabel)
        firstQueue.setSpecific(key: labelKey, value: firstQueueLabel)
        let secondQueue = DispatchQueue(label: secondQueueLabel, attributes: DispatchQueue.Attributes.concurrent)
        secondQueue.setSpecific(key: labelKey, value: secondQueueLabel)

        let firstListener = NSObject()
        let secondListener = NSObject()

        let firstExpectation = expectation(description: "firstDispatchOnQueue")
        emitter.onInt.subscribe(with: firstListener, callback: { (argument) in
            let currentQueueLabel = DispatchQueue.getSpecific(key: labelKey)
            XCTAssertTrue(firstQueueLabel == currentQueueLabel)
            firstExpectation.fulfill()
        }).onQueue(firstQueue)
        let secondExpectation = expectation(description: "secondDispatchOnQueue")
        emitter.onInt.subscribe(with: secondListener, callback: { (argument) in
            let currentQueueLabel = DispatchQueue.getSpecific(key: labelKey)
            XCTAssertTrue(secondQueueLabel == currentQueueLabel)
            secondExpectation.fulfill()
        }).onQueue(secondQueue)

        emitter.onInt.fire(10)

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testUsesCurrentQueueByDefault() {
        let queueLabel = "com.signals.queue";

        let labelKey = DispatchSpecificKey<String>()
        let queue = DispatchQueue(label: queueLabel, attributes: DispatchQueue.Attributes.concurrent)
        queue.setSpecific(key: labelKey, value: queueLabel)

        let observer = NSObject()
        let expectation = self.expectation(description: "receivedCallbackOnQueue")

        emitter.onInt.subscribe(with: observer, callback: { (argument) in
            let currentQueueLabel = DispatchQueue.getSpecific(key: labelKey)
            XCTAssertTrue(queueLabel == currentQueueLabel)
            expectation.fulfill()
        })

        queue.async {
            self.emitter.onInt.fire(10)
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
