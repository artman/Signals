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
    let onNoParams = Signal<()>()
    let onInt = Signal<Int>()
    let onString = Signal<String>()
    let onIntAndString = Signal<(intArgument: Int, stringArgument: String)>()
}