//
//  OffenceListDisplayable.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class OffenceListDisplayable: CustomSearchDisplayable {

    public var section: String?
    public var image: UIImage?
    public var title: String?
    public var subtitle: String?

    public func contains(_ searchText: String) -> Bool {
        return true
    }

    public init(offence: Offence) {
        title = offence.title
        subtitle = "\(offence.demeritValue) Demerit Point" + (offence.demeritValue > 0 ? "s" : "") + ", $\(String(format: "%.2f", offence.fineValue)) Fine"
    }
}
