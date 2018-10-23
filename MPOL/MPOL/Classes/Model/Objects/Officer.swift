//
//  Officer.swift
//  MPOL
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

@objc(MPLOfficer)
open class Officer: MPOLKitEntity, Identifiable {

    override open class var serverTypeRepresentation: String {
        return "officer"
    }

    private enum CodingKeys: String, CodingKey {
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
    open var employeeNumber: String
    open var region: String?

    // TODO: Proper Involvements
    open var involvements: [String] = []

    public override init(id: String) {
        employeeNumber = ""
        super.init(id: id)
    }

    public required init(unboxer: Unboxer) throws {

        givenName = unboxer.unbox(key: CodingKeys.givenName.rawValue)
        middleNames = unboxer.unbox(key: CodingKeys.middleNames.rawValue)
        familyName = unboxer.unbox(key: CodingKeys.familyName.rawValue)
        rank = unboxer.unbox(key: CodingKeys.rank.rawValue)
        employeeNumber = unboxer.unbox(key: CodingKeys.employeeNumber.rawValue) ?? ""
        region = unboxer.unbox(key: CodingKeys.region.rawValue)

        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {

        givenName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.givenName.rawValue) as String?
        middleNames = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.middleNames.rawValue) as String?
        familyName = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.familyName.rawValue) as String?
        rank = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.rank.rawValue) as String?
        employeeNumber = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.employeeNumber.rawValue) as String? ?? ""
        region = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.region.rawValue) as String?

        super.init(coder: aDecoder)
    }

    open override func encode(with aCoder: NSCoder) {

        aCoder.encode(givenName, forKey: CodingKeys.givenName.rawValue)
        aCoder.encode(middleNames, forKey: CodingKeys.middleNames.rawValue)
        aCoder.encode(familyName, forKey: CodingKeys.familyName.rawValue)
        aCoder.encode(rank, forKey: CodingKeys.rank.rawValue)
        aCoder.encode(employeeNumber, forKey: CodingKeys.employeeNumber.rawValue)
        aCoder.encode(region, forKey: CodingKeys.region.rawValue)

        super.encode(with: aCoder)
    }

    public required init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: CodingKeys.self)
        givenName = try values.decodeIfPresent(String.self, forKey: .givenName)
        familyName = try values.decodeIfPresent(String.self, forKey: .familyName)
        middleNames = try values.decodeIfPresent(String.self, forKey: .middleNames)
        rank = try values.decodeIfPresent(String.self, forKey: .rank)
        region = try values.decodeIfPresent(String.self, forKey: .region)
        employeeNumber = try values.decodeIfPresent(String.self, forKey: .employeeNumber) ?? ""

        try super.init(from: decoder) 
    }

    open override func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(givenName, forKey: .givenName)
        try container.encodeIfPresent(familyName, forKey: .familyName)
        try container.encodeIfPresent(middleNames, forKey: .middleNames)
        try container.encodeIfPresent(rank, forKey: .rank)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(employeeNumber, forKey: .employeeNumber)

        try super.encode(to: encoder)
    }

    // MARK: - Equality

    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Officer {
            return object.id == self.id
        }
        return super.isEqual(object)
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
}
