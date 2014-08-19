//
//  SignalListener.swift
//  Signals
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation

class TestListener {

    var dispatchCount:Int = 0;
    var lastArgument:Int = 0;
    
    func listenTo(emitter:SignalEmitter) {
        emitter.onInt.listen(self, callback: {
            [unowned self] (argument) in
            self.dispatchCount++
            self.lastArgument = argument;
        })
    }
}