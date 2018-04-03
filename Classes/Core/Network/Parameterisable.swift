//
//  Parameterisable.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol Parameterisable {
    var parameters: [String: Any] { get }
}

// FIXME: Uncomment when everyone has updated to Xcode 9.3 please.
/*
extension Dictionary: Parameterisable where Key == String, Value == Any {

    public var parameters: [String : Any] {
        return self

    }
}
*/
