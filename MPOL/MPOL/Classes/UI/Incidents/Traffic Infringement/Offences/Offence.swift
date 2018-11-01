//
//  Offence.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class Offence: Codable, Equatable, Hashable {

    public let id: String = UUID().uuidString
    public let title: String
    public let demeritValue: Int
    public let fineValue: Float

    public init(title: String, demeritValue: Int, fineValue: Float) {
        self.title = title
        self.demeritValue = demeritValue
        self.fineValue = fineValue
    }

    public var hashValue: Int {
        return id.hashValue
    }

    public static func == (lhs: Offence, rhs: Offence) -> Bool {
        return lhs.id == rhs.id
    }

}
