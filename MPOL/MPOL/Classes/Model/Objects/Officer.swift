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

    // MARK: - Class

    open override class var serverTypeRepresentation: String {
        return "officer"
    }

    // MARK: - Properties

    open var employeeNumber: String?
    open var familyName: String?
    open var givenName: String?
    open var middleNames: String?
    open var rank: String?
    open var region: String?

    // MARK: - Transient

    open var involvements: [String] = []

    // MARK: - Init

    public override init(id: String) {
        super.init(id: id)
    }

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {

        givenName = unboxer.unbox(key: CodingKeys.givenName.rawValue)
        middleNames = unboxer.unbox(key: CodingKeys.middleNames.rawValue)
        familyName = unboxer.unbox(key: CodingKeys.familyName.rawValue)
        rank = unboxer.unbox(key: CodingKeys.rank.rawValue)
        employeeNumber = unboxer.unbox(key: CodingKeys.employeeNumber.rawValue)
        region = unboxer.unbox(key: CodingKeys.region.rawValue)

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case employeeNumber
        case familyName
        case givenName
        case middleNames
        case rank
        case region
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        employeeNumber = try container.decodeIfPresent(String.self, forKey: .employeeNumber)
        familyName = try container.decodeIfPresent(String.self, forKey: .familyName)
        givenName = try container.decodeIfPresent(String.self, forKey: .givenName)
        middleNames = try container.decodeIfPresent(String.self, forKey: .middleNames)
        rank = try container.decodeIfPresent(String.self, forKey: .rank)
        region = try container.decodeIfPresent(String.self, forKey: .region)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(employeeNumber, forKey: CodingKeys.employeeNumber)
        try container.encode(familyName, forKey: CodingKeys.familyName)
        try container.encode(givenName, forKey: CodingKeys.givenName)
        try container.encode(middleNames, forKey: CodingKeys.middleNames)
        try container.encode(rank, forKey: CodingKeys.rank)
        try container.encode(region, forKey: CodingKeys.region)
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
