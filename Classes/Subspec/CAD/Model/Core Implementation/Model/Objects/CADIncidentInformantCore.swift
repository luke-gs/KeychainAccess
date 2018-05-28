//
//  SyncDetailsInformant.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of class representing an incident informant
open class CADIncidentInformantCore: Codable, CADIncidentInformantType {

    // MARK: - Network

    open var fullName: String?

    open var primaryPhone: String?

    open var secondaryPhone: String?
    
    open var address: String?
    
    open var shouldFollowUp: Bool?

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case fullName = "fullName"
        case primaryPhone = "primaryPhone"
        case secondaryPhone = "secondaryPhone"
        case address = "fullAddress"
        case shouldFollowUp = "shouldFollowUp"
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try values.decodeIfPresent(String.self, forKey: .fullName)
        primaryPhone = try values.decodeIfPresent(String.self, forKey: .primaryPhone)
        secondaryPhone = try values.decodeIfPresent(String.self, forKey: .secondaryPhone)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        shouldFollowUp = try values.decodeIfPresent(Bool.self, forKey: .shouldFollowUp) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        MPLUnimplemented()
    }
}
