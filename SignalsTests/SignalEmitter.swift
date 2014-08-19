//
//  SignalEmitter.swift
//  Signals
//
//  Created by Tuomas Artman on 16.8.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation

class SignalEmitter {

    let onInt = Signal<(argument:Int)>()
    let onString = Signal<(argument:String)>()
    let onIntAndString = Signal<(argument1:Int, argument2:String)>()
    
}