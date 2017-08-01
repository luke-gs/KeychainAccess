//
//  MPOLKitEntity.swift
//  MPOLKit
//
//  Created by Herli Halim on 31/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

public protocol MPOLKitEntityProtocol {
    var id: String { get }
    static var serverTypeRepresentation: String { get }
}
