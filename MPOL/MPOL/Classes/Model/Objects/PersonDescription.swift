//
//  PersonDescription.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Unbox
import PublicSafetyKit

@objc(MPLPersonDescription)
open class PersonDescription: IdentifiableDataModel {

    // MARK: - Properties

    public var build: String?
    public var createdBy: String?
    public var dateCreated: Date?
    public var dateUpdated: Date?
    public var effectiveDate: Date?
    public var entityType: String?
    public var ethnicity: String?
    public var expiryDate: Date?
    public var eyeColour: String?
    public var hairColour: String?
    public var height: Int?
    public var image: Media?
    public var imageThumbnail: Media?
    public var isSummary: Bool = false
    public var jurisdiction: String?
    public var marks: [String]?
    public var race: String?
    public var remarks: String?
    public var source: MPOLSource?
    public var updatedBy: String?
    public var weight: String?

    public override init(id: String) {
        super.init(id: id)
    }

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: PersonDescription.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: PersonDescription.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: PersonDescription.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: PersonDescription.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")

        height = unboxer.unbox(key: "height")
        weight = unboxer.unbox(key: "weight")
        ethnicity = unboxer.unbox(key: "ethnicity")
        race = unboxer.unbox(key: "race")
        build = unboxer.unbox(key: "build")
        hairColour = unboxer.unbox(key: "hairColour")
        eyeColour = unboxer.unbox(key: "eyeColour")
        marks = unboxer.unbox(key: "identifyingMarks")
        remarks = unboxer.unbox(key: "remarks")
        imageThumbnail = unboxer.unbox(key: "imageThumbnail")
        image = unboxer.unbox(key: "image")

        jurisdiction = unboxer.unbox(key: "jurisdiction")

        try super.init(unboxer: unboxer)
    }

    public func formatted() -> String? {
        var primaryComponents: [String] = []
        var secondaryComponents: [String] = []

        if let height = height {
            primaryComponents.append("\(height) cm")
        }

        if let weight = weight?.ifNotEmpty() {
            primaryComponents.append("\(weight) kg")
        }

        if let ethnicity = ethnicity?.ifNotEmpty() {
            primaryComponents.append("\(ethnicity.localizedCapitalized) speaking")
        }

        if let race = race?.ifNotEmpty() {
            primaryComponents.append("\(race.localizedCapitalized) appearance")
        }

        if let build = build?.ifNotEmpty() {
            primaryComponents.append("\(build.localizedLowercase)" + " build")
        }

        if let hairColour = hairColour?.ifNotEmpty()?.localizedLowercase {
            primaryComponents.append("\(hairColour.localizedLowercase) hair")
        }

        if let eyeColour = eyeColour?.ifNotEmpty() {
            primaryComponents.append(eyeColour.localizedLowercase + " eyes")
        }

        if let marks = marks {
            secondaryComponents.append(marks.joined(separator: ", "))
        }

        if let remarks = remarks?.ifNotEmpty() {
            secondaryComponents.append(String(remarks.first!).uppercased() + String(remarks.dropFirst()))
        }

        if primaryComponents.isEmpty && secondaryComponents.isEmpty {
            return nil
        }

        let locationString = jurisdiction != nil ? " (\(jurisdiction!))" : ""

        return primaryComponents.joined(separator: ", ") + (!primaryComponents.isEmpty ? ". " : "") + secondaryComponents.joined(separator: ", ") + locationString + (!secondaryComponents.isEmpty || !locationString.isEmpty ? "." : "")
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case build
        case createdBy
        case dateCreated
        case dateUpdated
        case effectiveDate
        case entityType
        case ethnicity
        case expiryDate
        case eyeColour
        case hairColour
        case height
        case image
        case imageThumbnail
        case isSummary
        case jurisdiction
        case marks
        case race
        case remarks
        case source
        case updatedBy
        case weight
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        build = try container.decodeIfPresent(String.self, forKey: .build)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        ethnicity = try container.decodeIfPresent(String.self, forKey: .ethnicity)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        eyeColour = try container.decodeIfPresent(String.self, forKey: .eyeColour)
        hairColour = try container.decodeIfPresent(String.self, forKey: .hairColour)
        height = try container.decodeIfPresent(Int.self, forKey: .height)
        image = try container.decodeIfPresent(Media.self, forKey: .image)
        imageThumbnail = try container.decodeIfPresent(Media.self, forKey: .imageThumbnail)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        jurisdiction = try container.decodeIfPresent(String.self, forKey: .jurisdiction)
        marks = try container.decodeIfPresent([String].self, forKey: .marks)
        race = try container.decodeIfPresent(String.self, forKey: .race)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        weight = try container.decodeIfPresent(String.self, forKey: .weight)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(build, forKey: CodingKeys.build)
        try container.encode(createdBy, forKey: CodingKeys.createdBy)
        try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(entityType, forKey: CodingKeys.entityType)
        try container.encode(ethnicity, forKey: CodingKeys.ethnicity)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(eyeColour, forKey: CodingKeys.eyeColour)
        try container.encode(hairColour, forKey: CodingKeys.hairColour)
        try container.encode(height, forKey: CodingKeys.height)
        try container.encode(image, forKey: CodingKeys.image)
        try container.encode(imageThumbnail, forKey: CodingKeys.imageThumbnail)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(jurisdiction, forKey: CodingKeys.jurisdiction)
        try container.encode(marks, forKey: CodingKeys.marks)
        try container.encode(race, forKey: CodingKeys.race)
        try container.encode(remarks, forKey: CodingKeys.remarks)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
        try container.encode(weight, forKey: CodingKeys.weight)
    }

}
