//
//  CADBookOffRequestCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// PSCore implementation of book off request
open class CADBookOffRequestCore: CADBookOffRequestType {

    public init(callsign: String) {
        self.callsign = callsign
    }

    // MARK: - Request Parameters

    /// The callsign for the resource.
    open var callsign: String

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case callsign
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(callsign, forKey: CodingKeys.callsign)
    }
}
