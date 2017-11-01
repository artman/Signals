//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

import Foundation
import Signals

class TestListener {
    var dispatchCount: Int = 0;
    var lastArgument: Int = 0;
    
    func subscribe(to emitter: SignalEmitter) {
        emitter.onInt.subscribe(with: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }
    
    func subscribeOnce(to emitter: SignalEmitter) {
        emitter.onInt.subscribeOnce(with: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }

    func subscribePastOnce(to emitter: SignalEmitter) {
        emitter.onInt.subscribePastOnce(with: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument
        })
    }

    func subscribePast(to emitter: SignalEmitter) {
        emitter.onInt.subscribePast(with: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }
}
