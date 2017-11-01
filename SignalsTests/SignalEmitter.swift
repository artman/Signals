//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

import Foundation
import Signals

class SignalEmitter {
    let onNoParams = Signal<()>(retainLastData: true)
    let onInt = Signal<Int>(retainLastData: true)
    let onString = Signal<String>(retainLastData: true)
    let onIntAndString = Signal<(intArgument: Int, stringArgument: String)>(retainLastData: true)
}
