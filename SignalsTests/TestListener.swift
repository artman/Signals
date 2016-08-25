//
//  SignalListener.swift
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
    
    func listenTo(_ emitter: SignalEmitter) {
        emitter.onInt.listen(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }
    
    func listenOnceTo(_ emitter: SignalEmitter) {
        emitter.onInt.listenOnce(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }

    func listenPastOnceTo(_ emitter: SignalEmitter) {
        emitter.onInt.listenPastOnce(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument
        })
    }

    func listenPastTo(_ emitter: SignalEmitter) {
        emitter.onInt.listenPast(on: self, callback: {
            [unowned self] (argument) in
            self.dispatchCount += 1
            self.lastArgument = argument;
        })
    }
}
