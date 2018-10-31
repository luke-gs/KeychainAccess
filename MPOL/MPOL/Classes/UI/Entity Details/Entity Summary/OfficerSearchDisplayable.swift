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
        guard let title = formattedName else { return NSLocalizedString("Name Unknown", comment: "") }

        let employeeNumberCount = (officer.employeeNumber?.count ?? 0) + 2
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15), range: NSRange(location: (title.count - employeeNumberCount), length: employeeNumberCount))
        return attributedString
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

    private var formattedName: String? {
        let lastNameString = officer.familyName != nil ? "\(officer.familyName!)," : ""
        let employeeNumberString = "(\(officer.employeeNumber ?? "Employee Number Unknown"))"
        return [lastNameString, officer.givenName, employeeNumberString].joined()
    }

}
