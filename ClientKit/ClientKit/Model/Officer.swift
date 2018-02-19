//
//  Officer.swift
//  ClientKit
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class Officer: MPOLKitEntity, Identifiable {

    override open class var serverTypeRepresentation: String {
        return "officer"
    }

    enum CodingKeys: String, CodingKey {
        case givenName
        case surname
        case middleNames
    }

    open var givenName: String?
    open var surname: String?
    open var middleNames: String?
    open var rank: String?
    open var employeeNumber: String?
    open var region: String?

    // TODO: Proper Involvements
    open var involvements: [String] = []
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

        size = CGSize(width: 48, height: 48)
    }

    override func loadImage(completion: @escaping (ImageSizable) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {

            var image = #imageLiteral(resourceName: "Avatar 1").sizing()
            image.size = self.size
            image.contentMode = .scaleAspectFit

            completion(image)
        }
    }

}
