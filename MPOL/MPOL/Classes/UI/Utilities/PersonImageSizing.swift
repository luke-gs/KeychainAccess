//
//  PersonImageSizing.swift
//  MPOL
//
//  Created by Herli Halim on 2/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class PersonImageSizing: AsynchronousImageSizing {

    public let person: Person

    public init(person: Person) {
        self.person = person

        let thumbnailSizing: ImageSizing?

        if person.initials?.isEmpty ?? true == false {
            let image = person.initialThumbnail.withRenderingMode(.alwaysTemplate)
            thumbnailSizing = ImageSizing(image: image, size: image.size, contentMode: .scaleAspectFill)
        } else {
            thumbnailSizing = nil
        }

        super.init(placeholderImage: thumbnailSizing)
    }

    public override func loadImage(completion: @escaping (ImageSizable) -> Void) {

        // Code to retrieve image goes here
        if let url = person.thumbnailUrl {
            _ = ImageDownloader.default.fetch(for: url).done { image -> Void in
                let sizing = ImageSizing(image: image, size: image.size, contentMode: .scaleAspectFit)
                completion(sizing)
            }.cauterize()
        }

    }
}
