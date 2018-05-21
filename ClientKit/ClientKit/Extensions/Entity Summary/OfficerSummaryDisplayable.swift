//
//  OfficerSummaryDisplayable.swift
//  ClientKit
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class OfficerSummaryDisplayable: OfficerSearchDisplayable {
    override public var detail1: String? {
        return officer.involvements.joined(separator: ", ")
    }

    public override func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        if let image = image { return image }
        let imageSizing = OfficerImageSizing(entity: officer)
        return imageSizing
    }
}


