//
//  OfficerSummaryDisplayable.swift
//  MPOL
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class OfficerSummaryDisplayable: OfficerSearchDisplayable {
    override public var detail2: StringSizable? {

        let string = !officer.involvements.isEmpty ? officer.involvements.joined(separator: ", ") : "No involvements"

        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.foregroundColor, value: UIColor.brightBlue, range: NSRange(location: 0, length: string.count))
        return attributedString
    }

    public override func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        if let image = image {
            return image
        }
        let imageSizing = OfficerImageSizing(entity: officer)
        return imageSizing
    }
}
