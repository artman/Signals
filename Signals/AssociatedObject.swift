//
//  AssociatedObject.swift
//  Signals
//
//  Created by Tuomas Artman on 12/25/2015.
//  Copyright © 2015 Tuomas Artman. All rights reserved.
//

import ObjectiveC

func setAssociatedObject<T>(object: AnyObject, value: T, associativeKey: UnsafePointer<Void>, policy: objc_AssociationPolicy) {
    if let valueAsAnyObject = value as? AnyObject {
        objc_setAssociatedObject(object, associativeKey, valueAsAnyObject, policy)
    }
}

func getAssociatedObject<T>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
    if let valueAsType = objc_getAssociatedObject(object, associativeKey) as? T {
        return valueAsType
    } else {
        return nil
    }
}

func getOrCreateAssociatedObject<T>(object: AnyObject, associativeKey: UnsafePointer<Void>, defaultValue:T, policy: objc_AssociationPolicy) -> T {
    if let valueAsType: T = getAssociatedObject(object, associativeKey: associativeKey) {
        return valueAsType
    }
    setAssociatedObject(object, value: defaultValue, associativeKey: associativeKey, policy: policy)
    return defaultValue;
}
