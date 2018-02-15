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
        return OfficerImageSizing(entity: officer)
    }
}

class OfficerImageSizing: EntityImageSizing<Officer> {

    override init(entity: Officer) {
        super.init(entity: entity)

        let thumbnailSizing: ImageSizing?

        if entity.initials?.isEmpty ?? true == false {
            let image = entity.initialImage().withCircleBackground(tintColor: .lightGray,
                                                                   circleColor: .gray,
                                                                   style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                 padding: CGSize(width: 0, height: 0)),
                                                                   shouldCenterImage: true)
            thumbnailSizing = ImageSizing(image: image, size: image?.size ?? .zero, contentMode: .scaleAspectFill)
        } else {
            thumbnailSizing = nil
        }

        placeholderImage = thumbnailSizing
    }

}
