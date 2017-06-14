//
//  EntitySource.swift
//  MPOLKit
//
//  Created by Herli Halim on 8/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol EntitySource {
    
    /// The name used to reference this source to the server.
    var serverSourceName: String { get }
    
    /// The appropriate text to describe the source in the badge.
    var localizedBadgeTitle: String { get }
    
    /// The appropriate text to describe the source in a smaller space.
    var localizedBarTitle: String { get }
    
}
