//
//  SignalSuspensionTests.swift
//  Signals
//
//  Created by Marco on 01/12/16.
//  Copyright © 2016 Tuomas Artman. All rights reserved.
//

import Foundation
import XCTest
@testable import Signals
#if os(Linux)
    import Dispatch
#endif

class SignalSuspensionTests: XCTestCase {
    var emitter:SignalEmitter = SignalEmitter();

    override func setUp() {
        super.setUp()
        emitter = SignalEmitter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSuspensionBlocksCallback() {
        var called = false
        let subscription = emitter.onInt.subscribe(on: self) { (argument) in
            called = true
        }
        
        emitter.onInt.fire(1)
        XCTAssertTrue(called)
        
        called = false
        subscription.suspended = true
        emitter.onInt.fire(1)
        XCTAssertFalse(called)
    }
    
    func testResumeInvokesCallback() {
        var number: Int? = nil
        
        let subscription = emitter.onInt.subscribe(on: self) { (argument) in
            number = argument
        }

        subscription.suspended = true
        emitter.onInt.fire(1)
        XCTAssert(number == nil)
        
        subscription.suspended = false
        XCTAssertEqual(number!, 1)
    }
    
    func testResumeInvokesCallbackOnce() {
        var invocationCount = 0
        var number: Int? = nil
        
        let subscription = emitter.onInt.subscribe(on: self) { (argument) in
            invocationCount += 1
            number = argument
        }
        
        subscription.suspended = true
        
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)
        emitter.onInt.fire(3)
        
        subscription.suspended = false
        XCTAssertEqual(number!, 3)
        XCTAssertEqual(invocationCount, 1)
    }
    
    func testDataMerge() {
        var number: Int? = nil
        
        var subscription = emitter.onInt.subscribe(on: self) { (argument) in
            number = argument
        }
        
        // Merge data with a sum
        subscription = subscription.mergeData(with: { (number, oldNumber) -> Int in
            return (oldNumber ?? 0) + number
        })
        
        subscription.suspended = true
        
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)
        emitter.onInt.fire(3)
        
        subscription.suspended = false
        XCTAssertEqual(number!, 6)
    }
}
