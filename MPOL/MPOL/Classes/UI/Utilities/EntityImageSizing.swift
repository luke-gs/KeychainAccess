//
//  EntityImageSizing.swift
//  MPOL
//
//  Created by QHMW64 on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class EntityImageSizing<T: Identifiable>: AsynchronousImageSizing {
    public let entity: T

    public init(entity: T) {
        self.entity = entity

        let thumbnailSizing: ImageSizing?

        if entity.initials?.isEmpty ?? true == false {
            let image = entity.initialImage()
            thumbnailSizing = ImageSizing(image: image, size: image.size, contentMode: .scaleAspectFill)
        } else {
            thumbnailSizing = nil
        }

        super.init(placeholderImage: thumbnailSizing)
    }

    public override func loadImage(completion: @escaping (ImageSizable) -> Void) {

        // Code to retrieve image goes here
        /*
         let url = URL(string: "https://www.someawesomeimage.com")!
         _ = ImageDownloader.default.fetchImage(using: url).then { image -> Void in
         let sizing = ImageSizing(image: image, size: image.size, contentMode: .scaleAspectFit)
         completion(sizing)
         }
         */
    }
}
