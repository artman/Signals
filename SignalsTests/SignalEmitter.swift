//
//  SignalEmitter.swift
//  Signals
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation
import Signals

class SignalEmitter {
    let onNoParams = Signal<()>(retainLastData: true)
    let onInt = Signal<Int>(retainLastData: true)
    let onString = Signal<String>(retainLastData: true)
    let onIntAndString = Signal<(intArgument: Int, stringArgument: String)>(retainLastData: true)
    let onNoRetention = Signal<String>(retainLastData: false)
}