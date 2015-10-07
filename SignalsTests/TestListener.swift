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
    
    func listenTo(emitter: SignalEmitter) {
        emitter.onInt.listen(self, callback: {
            [unowned self] (argument) in
            self.dispatchCount++
            self.lastArgument = argument;
        })
    }
    
    func listenOnceTo(emitter: SignalEmitter) {
        emitter.onInt.listenOnce(self, callback: {
            [unowned self] (argument) in
            self.dispatchCount++
            self.lastArgument = argument;
        })
    }

    func listenPastOnceTo(emitter: SignalEmitter) {
        emitter.onInt.listenPastOnce(self, callback: {
            [unowned self] (argument) in
            self.dispatchCount++
            self.lastArgument = argument
        })
    }

    func listenPastTo(emitter: SignalEmitter) {
        emitter.onInt.listenPast(self, callback: {
            [unowned self] (argument) in
            self.dispatchCount++
            self.lastArgument = argument;
        })
    }
}