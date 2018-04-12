//
//  AnyActivityLauncher.swift
//  MPOLKit
//
//  Created by Herli Halim on 4/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// The subclass that allows `Any` activity, when it makes sense to do so.
public final class AnyActivityLauncher: BaseActivityLauncher<AnyActivity> { }

public struct AnyActivity: ActivityType {

    private let _box: _AnyActivityBase

    public init<T: ActivityType>(_ activityType: T) {
        _box = _AnyActivityBox(activityType)
    }

    public var name: String {
        return _box.name
    }

    public var parameters: [String : Any] {
        return _box.parameters
    }

}

fileprivate class _AnyActivityBase {
    init() {
        guard type(of: self) != _AnyActivityBase.self else {
            fatalError("_AnyActivityBase instances can not be created. Create a subclass instance instead.")
        }
    }

    var name: String {
        MPLRequiresConcreteImplementation()
    }

    var parameters: [String: Any] {
        MPLRequiresConcreteImplementation()
    }
}

fileprivate class _AnyActivityBox<T: ActivityType>: _AnyActivityBase {

    let value: T

    init(_ value: T) {
        self.value = value
    }

    override var name: String {
        return value.name
    }

    override var parameters: [String: Any] {
        return value.parameters
    }
}

