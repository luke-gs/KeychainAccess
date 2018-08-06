//
//  Weak.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Wraps any object of type WeakObject inside, using a weak reference
/// Allows that the decleration of the actual objects can be lets and the
/// internal weak property is hidden away, with properties to acccess it.
public struct Weak<T: AnyObject> {

    // The weak reference to the object
    private weak var _object: T?

    // Used to access the underlying weak object and to prevent
    // the unwanted mutation of the underlying object
    public var object: T? {
        return _object
    }

    public init(_ object: T?) {
        self._object = object
    }
}

/// Useful methods in order to encode and decode Weak wrapped objects
public extension NSCoder {

    func encodeWeakObject<T: AnyObject>(weakObject: Weak<T>?, forKey key: String) {
        guard let weakObject = weakObject else { return }
        self.encode(weakObject.object, forKey: key)
    }

    func decodeWeakObject<T: AnyObject & NSCoding>(forKey key: String) -> Weak<T> {
        let object = self.decodeObject(forKey: key) as? T
        return Weak(object)
    }
}
