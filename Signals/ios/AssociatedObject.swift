//
//  Copyright (c) 2014 - 2017 Tuomas Artman. All rights reserved.
//

import ObjectiveC

func setAssociatedObject<T>(_ object: AnyObject, value: T, associativeKey: UnsafeRawPointer, policy: objc_AssociationPolicy) {
    objc_setAssociatedObject(object, associativeKey, value, policy)
}

func getAssociatedObject<T>(_ object: AnyObject, associativeKey: UnsafeRawPointer) -> T? {
    if let valueAsType = objc_getAssociatedObject(object, associativeKey) as? T {
        return valueAsType
    } else {
        return nil
    }
}

func getOrCreateAssociatedObject<T>(_ object: AnyObject, associativeKey: UnsafeRawPointer, defaultValue:T, policy: objc_AssociationPolicy) -> T {
    if let valueAsType: T = getAssociatedObject(object, associativeKey: associativeKey) {
        return valueAsType
    }
    setAssociatedObject(object, value: defaultValue, associativeKey: associativeKey, policy: policy)
    return defaultValue
}
