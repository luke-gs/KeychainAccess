//
//  ClientModelTypes.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Class for handling client specific model type overrides. Defaults are PSCore types
open class ClientModelTypes {

    /// The type used for a resource status
    static open var resourceStatus: ResourceStatusType.Type = ResourceStatusCore.self

}
