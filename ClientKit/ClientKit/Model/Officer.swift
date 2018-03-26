//
//  Officer.swift
//  ClientKit
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Unbox

open class Officer: MPOLKitEntity, Identifiable {

    override open class var serverTypeRepresentation: String {
        return "officer"
    }

    enum CodingKey: String {
        case givenName
        case familyName
        case middleNames
        case rank
        case region
        case employeeNumber
    }

    open var givenName: String?
    open var familyName: String?
    open var middleNames: String?
    open var rank: String?
    open var employeeNumber: String?
    open var region: String?

    // TODO: Proper Involvements
    open var involvements: [String] = []

    public init() {
        super.init()
    }

    public required init(unboxer: Unboxer) throws {
        do { try super.init(unboxer: unboxer) }

        givenName = unboxer.unbox(key: CodingKey.givenName.rawValue)
        middleNames = unboxer.unbox(key: CodingKey.middleNames.rawValue)
        familyName = unboxer.unbox(key: CodingKey.familyName.rawValue)
        rank = unboxer.unbox(key: CodingKey.rank.rawValue)
        employeeNumber = unboxer.unbox(key: CodingKey.employeeNumber.rawValue)
        region = unboxer.unbox(key: CodingKey.region.rawValue)

    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        givenName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.givenName.rawValue) as String!
        middleNames = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.middleNames.rawValue) as String!
        familyName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.familyName.rawValue) as String!
        rank = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.rank.rawValue) as String!
        employeeNumber = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.employeeNumber.rawValue) as String!
        region = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.region.rawValue) as String!
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(givenName, forKey: CodingKey.givenName.rawValue)
        aCoder.encode(middleNames, forKey: CodingKey.middleNames.rawValue)
        aCoder.encode(familyName, forKey: CodingKey.familyName.rawValue)
        aCoder.encode(rank, forKey: CodingKey.rank.rawValue)
        aCoder.encode(employeeNumber, forKey: CodingKey.employeeNumber.rawValue)
        aCoder.encode(region, forKey: CodingKey.region.rawValue)
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
