//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

import Foundation
import XCTest
@testable import Signals
#if os(Linux)
import Dispatch
#endif

class SignalsTests: XCTestCase {
    
    var emitter:SignalEmitter = SignalEmitter()
    
    override func setUp() {
        super.setUp()
        #if DEBUG
            assertionHandlerOverride = nil
        #endif
        emitter = SignalEmitter()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_fire() {
        var intSignalResult = 0
        var stringSignalResult = ""
        
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            intSignalResult = argument
        })
        emitter.onString.subscribe(with: self, callback: { (argument) in
            stringSignalResult = argument
        })
        
        emitter.onInt.fire(1)
        emitter.onString.fire("test")
        
        XCTAssertEqual(intSignalResult, 1, "IntSignal catched")
        XCTAssertEqual(stringSignalResult, "test", "StringSignal catched")
    }
    
    func test_fire_noArgument() {
        var signalCount = 0
        
        emitter.onNoParams.subscribe(with: self, callback: { () -> Void in
            signalCount += 1
        })
        
        emitter.onNoParams.fire()
        
        XCTAssertEqual(signalCount, 1, "Signal catched")
    }

    func test_fire_multiArgument() {
        var intSignalResult = 0
        var stringSignalResult = ""
        
        emitter.onIntAndString.subscribe(with: self, callback: { (argument1, argument2) -> Void in
            intSignalResult = argument1
            stringSignalResult = argument2
        })
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(intSignalResult, 1, "argument1 catched")
        XCTAssertEqual(stringSignalResult, "test", "argument2 catched")
    }
    
    func test_fire_multipleTimes_shouldCallSubcriptionsMultipletimes() {
        var dispatchCount = 0
        var lastArgument = 0
        
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            dispatchCount += 1
            lastArgument = argument
        })
        
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)

        XCTAssertEqual(dispatchCount, 2, "Dispatched two times")
        XCTAssertEqual(lastArgument, 2, "Last argument catched with value 2")
    }
    
    func test_fire_whenMultipleSubcribers_shouldCallAllSubscribers() {
        var dispatchCount = 0
        var lastArgument = 0
        
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            dispatchCount += 1
            lastArgument = argument
        })
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            dispatchCount += 1
            lastArgument = argument + 1
        })
        
        emitter.onInt.fire(1)

        XCTAssertEqual(dispatchCount, 2, "Dispatched two times")
        XCTAssertEqual(lastArgument, 2, "Last argument catched with value 2")
    }
    
    func test_subscribeOnce() {
        let observer1 = TestListener()
        let observer2 = TestListener()
        let observer3 = TestListener()
        
        observer1.subscribe(to: emitter)
        observer2.subscribeOnce(to: emitter)
        observer3.subscribePast(to: emitter)
        
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)
        
        XCTAssertEqual(observer1.dispatchCount, 2, "Dispatched two times")
        XCTAssertEqual(observer2.dispatchCount, 1, "Dispatched one time")
        XCTAssertEqual(observer3.dispatchCount, 2, "Dispatched two times")
    }
    
    func test_subscribePastOnce_whenAlreadyFired_shouldImmediatelyFireOnce() {
        let observer = TestListener()

        emitter.onInt.fire(1)
        emitter.onInt.fire(2)
        observer.subscribePastOnce(to: emitter)
        emitter.onInt.fire(3)
        emitter.onInt.fire(4)

        XCTAssertEqual(observer.dispatchCount, 1, "Dispatched once")
        XCTAssertEqual(observer.lastArgument, 2, "Remembered the most recent data")
    }
    
    func test_subscribePastOnce_whenNotRetainingPastData_shouldAssert() {
        #if DEBUG
            var assertionCalled = false
            assertionHandlerOverride = { (condition, _) in
                XCTAssertEqual(condition, false, "Should assert because signal doesnt retain past data")
                assertionCalled = true
            }
            
            let signal = Signal<Void>()
            signal.subscribePastOnce(with: self) {}
            XCTAssertEqual(assertionCalled, true, "Should assert because signal doesnt retain past data")
        #endif
    }

    func test_subscribePastOnce_whenNotYetFired_shouldObserveNext() {
        let observer = TestListener()

        observer.subscribePastOnce(to: emitter)
        emitter.onInt.fire(1)
        emitter.onInt.fire(2)

        XCTAssertEqual(observer.dispatchCount, 1, "Dispatched once")
        XCTAssertEqual(observer.lastArgument, 1, "Remembered only the relevant data")
    }

    func test_cancelSubscription() {
        var dispatchCount: Int = 0
        
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            dispatchCount += 1
        })
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            dispatchCount += 1
        })
        
        emitter.onInt.cancelSubscription(for: self)
        emitter.onInt.fire(1)
        
        XCTAssertEqual(dispatchCount, 0, "Shouldn't have catched signal fire")
    }
    
    func test_cancelAllSubscriptions() {
        var dispatchCount: Int = 0
        
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            dispatchCount += 1
        })
        emitter.onInt.subscribe(with: self, callback: { (argument) in
            dispatchCount += 1
        })
        
        emitter.onInt.cancelAllSubscriptions()
        emitter.onInt.fire(1)
        
        XCTAssertEqual(dispatchCount, 0, "Shouldn't have catched signal fire")
    }
    
    func test_autoRemoveWeakSubscribers() {
        var observer: TestListener? = TestListener()
        observer!.subscribe(to: emitter)
        observer = nil
        
        emitter.onInt.fire(1)

        XCTAssertEqual(emitter.onInt.observers.count, 0, "Weak observer should have been collected")
    }
    
    func test_subscribePast() {
        var intSignalResult = 0
        var stringSignalResult = ""
        var dispatchCount = 0
        
        emitter.onIntAndString => (intArgument: 1, stringArgument: "test")
        
        emitter.onIntAndString.subscribePast(with: self, callback: { (argument1, argument2) -> Void in
            intSignalResult = argument1
            stringSignalResult = argument2
            dispatchCount += 1
        })

        XCTAssertEqual(intSignalResult, 1, "argument1 catched")
        XCTAssertEqual(stringSignalResult, "test", "argument2 catched")
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 2, "Second fire catched")
    }
    
    func test_filter() {
        var intSignalResult = 0
        var stringSignalResult = ""
        var dispatchCount = 0
        
        emitter.onIntAndString.subscribe(with: self, callback: { (argument1, argument2) -> Void in
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
    
    func test_filter_whenMatching_shouldCancel() {
        var intSignalResult = 0
        var stringSignalResult = ""
        var dispatchCount = 0
        
        emitter.onIntAndString.subscribeOnce(with: self, callback: { (argument1, argument2) -> Void in
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
    
    func test_cancel() {
        var dispatchCount = 0
        
        let observer = emitter.onIntAndString.subscribe(with: self, callback: { (argument1, argument2) -> Void in
            dispatchCount += 1
        })
     
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        observer.cancel()
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")

        XCTAssertEqual(dispatchCount, 1, "Filtered fires")
    }
    
    func test_postSubscriptionNoData() {
        var dispatchCount = 0
        
        emitter.onNoParams.fire()
        
        emitter.onNoParams.subscribePast(with: self, callback: { () -> Void in
            dispatchCount += 1
        })
        
        XCTAssertEqual(dispatchCount, 1, "Catched signal fire")
    }
    
    func test_cancelSubscription_whenCancellingOwnSubscription() {
        var dispatchCount = 0
 
        emitter.onIntAndString.subscribeOnce(with: self) { (intArgument, stringArgument) -> Void in
            self.emitter.onIntAndString.cancelSubscription(for: self)
            dispatchCount += 1
        }
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 1, "Should have dispatched correct number of times")
    }
    
    func test_cancelSubscription_whenCancellingDuringFiring_shouldCancel() {
        var dispatchCount = 0
        
        let observer1 = NSObject()
        let observer2 = NSObject()
        let observer3 = NSObject()
        
        emitter.onIntAndString.subscribe(with: observer1) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        emitter.onIntAndString.subscribe(with: observer2) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.cancelSubscription(for: observer1)
        }
        emitter.onIntAndString.subscribe(with: observer3) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.cancelSubscription(for: observer2)
        }
        self.emitter.onIntAndString.cancelSubscription(for: observer2)
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")

        XCTAssertEqual(dispatchCount, 3+1, "Should have dispatched correct number of times")
    }
    
    func test_cancelSubscription_whenCancelingDuringFiring_shouldCancelOnlyTargetedSubscription() {
        var dispatchCount = 0
        
        let observer1 = NSObject()
        let observer2 = NSObject()
        let observer3 = NSObject()
        
        emitter.onIntAndString.subscribe(with: observer1) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.cancelSubscription(for: observer2)
        }
        emitter.onIntAndString.subscribe(with: observer2) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        emitter.onIntAndString.subscribe(with: observer3) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        self.emitter.onIntAndString.cancelSubscription(for: observer2)
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 2+2, "Should have dispatched correct number of times")
    }
    
    func test_cancelAllSubsciptions_whenCancellingDuringFiring_shouldNotCancelCurrentTargets() {
        var dispatchCount = 0
        
        let observer1 = NSObject()
        let observer2 = NSObject()
        let observer3 = NSObject()
        
        emitter.onIntAndString.subscribe(with: observer1) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
            self.emitter.onIntAndString.cancelAllSubscriptions()
        }
        emitter.onIntAndString.subscribe(with: observer2) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        emitter.onIntAndString.subscribe(with: observer3) { (intArgument, stringArgument) -> Void in
            dispatchCount += 1
        }
        self.emitter.onIntAndString.cancelSubscription(for: observer2)
        
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        emitter.onIntAndString => (intArgument:1, stringArgument:"test")
        
        XCTAssertEqual(dispatchCount, 1+1, "Should have dispatched correct number of times")
    }

    func test_lastDataFired() {
        emitter.onString.retainLastData = true
        emitter.onString => "Retain Data"
        XCTAssertNotNil(emitter.onString.lastDataFired, "Signal should have retained fired data")

        emitter.onString.retainLastData = false
        XCTAssertNil(emitter.onString.lastDataFired, "Signal should have cleared fired data")

        emitter.onString => "No Retention"
        XCTAssertNil(emitter.onString.lastDataFired, "Signal should not have retained fired data")
    }

    func test_fire_uperformance() {
        self.measure() {
            var dispatchCount = 0
            for _ in 0..<10 {
                self.emitter.onIntAndString.subscribe(with: self) { (argument1, argument2) -> Void in
                    dispatchCount += 1
                }
            }
            for _ in 0..<950 {
                self.emitter.onIntAndString => (intArgument:1, stringArgument:"test")
            }
        }
    }
}
