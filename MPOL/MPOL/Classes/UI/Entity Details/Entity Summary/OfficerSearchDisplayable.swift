//
//  OfficerSearchDisplayable.swift
//  MPOL
//
//  Created by QHMW64 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class OfficerSearchDisplayable: EntitySummaryDisplayable {
    public private(set) var officer: Officer

    public var image: ImageSizing?

    public required init(_ entity: MPOLKitEntity) {
        officer = entity as! Officer
    }

    public var category: String?

    public var title: StringSizable? {

        let lastNameString =  officer.familyName != nil ? "\(officer.familyName!)," : ""
        let names: String = [lastNameString, officer.givenName].joined(separator: "")
        let employeeNumberString = " (\(officer.employeeNumber ?? "Employee Number Unknown"))"

        let result = NSMutableAttributedString(string: names)
        result.append(employeeNumberString, font: UIFont.systemFont(ofSize: 15), color: nil)
        return result
    }

    public var detail1: StringSizable? {
        return officer.rank
    }

    public var detail2: StringSizable? {
        return nil
    }

    public var borderColor: UIColor?

    public var iconColor: UIColor?

    public var badge: UInt {
        return 0
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        if let image = image {
            return image
        }
        let imageSizing = EntityImageSizing(entity: officer)
        return imageSizing
    }
}
