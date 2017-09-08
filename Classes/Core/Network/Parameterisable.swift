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

/* Not possible, yet. :(
extension Dictionary: Parameterisable where Key == String, Value == Any {

    public var parameters: [String : Any] {
        return self

    }

}
*/
