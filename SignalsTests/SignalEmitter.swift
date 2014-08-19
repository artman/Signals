//
//  SignalEmitter.swift
//  Signals
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation

class SignalEmitter {

    let onInt = Signal<(Int)>()
    let onString = Signal<(String)>()
    let onIntAndString = Signal<(Int, String)>()
    
}