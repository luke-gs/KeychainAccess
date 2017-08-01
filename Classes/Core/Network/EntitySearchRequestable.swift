//
//  EntitySearchRequestable.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

public protocol EntitySearchRequestable: Parameterisable {
    associatedtype ResultClass: Unboxable, MPOLKitEntityProtocol
}
