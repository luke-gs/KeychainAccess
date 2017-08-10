//
//  EntityFetchRequestable.swift
//  MPOLKit
//
//  Created by Herli Halim on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

public protocol EntityFetchRequestable: Parameterisable {
    associatedtype ResultClass: MPOLKitEntityProtocol
}
