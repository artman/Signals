//
//  Observer.swift
//  Signals
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation
import Signals

class TestListener {
    var dispatchCount: Int = 0;
    var lastArgument: Int = 0;
    
    func subscribe(to emitter: SignalEmitter) {
        emitter.onInt.subscribe(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }
    
    func subscribeOnce(to emitter: SignalEmitter) {
        emitter.onInt.subscribeOnce(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }

    func subscribePastOnce(to emitter: SignalEmitter) {
        emitter.onInt.subscribePastOnce(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument
        })
    }

    func subscribePast(to emitter: SignalEmitter) {
        emitter.onInt.subscribePast(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }
}
