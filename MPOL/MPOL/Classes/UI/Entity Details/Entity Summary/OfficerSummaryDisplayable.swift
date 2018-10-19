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
    override public var detail1: String? {
        return !officer.involvements.isEmpty ? officer.involvements.joined(separator: ", ") : "No involvements"
    }

    public override func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        if let image = image { return image }
        let imageSizing = OfficerImageSizing(entity: officer)
        return imageSizing
    }
}
