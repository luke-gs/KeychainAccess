//
//  OfficerSearchDisplayable.swift
//  ClientKit
//
//  Created by QHMW64 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class OfficerSearchDisplayable: EntitySummaryDisplayable {
    public private(set) var officer: Officer

    public init(_ entity: MPOLKitEntity) {
        officer = entity as! Officer
    }

    public var category: String?

    public var title: String? {
        return formattedName ?? NSLocalizedString("Name Unknown", comment: "")
    }

    public var detail1: String? {
        return [officer.rank, officer.officerID].joined(separator: " \(ThemeConstants.dividerSeparator) ")
    }

    public var detail2: String?

    public var borderColor: UIColor?

    public var iconColor: UIColor?

    public var badge: UInt {
        return 0
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        return EntityImageSizing(entity: officer)
    }

    private var formattedName: String? {
        return [officer.givenName, officer.surname].joined(separator: " ")
    }

}
