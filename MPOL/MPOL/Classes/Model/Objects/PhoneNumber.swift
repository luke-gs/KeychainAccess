//
//  PhoneNumber.swift
//  Pods
//
//  Created by Gridstone on 7/6/17.
//
//

import Unbox
import PublicSafetyKit

@objc(MPLPhoneNumber)
open class PhoneNumber: DefaultModel {

    // MARK: - Properties

    open var areaCode: String?
    open var phoneNumber: String?
    open var type: String?

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {

        type = unboxer.unbox(key: "type")
        areaCode = unboxer.unbox(key: "areaCode")
        phoneNumber = unboxer.unbox(key: "phoneNumber")

        try super.init(unboxer: unboxer)
    }

    // MARK: - Temp Formatters

    func formattedNumber() -> String? {
        if let number = phoneNumber {
            if let areaCode = areaCode {
                return "\(areaCode) \(number)"
            } else {
                return number
            }
        }
        return nil
    }

    func formattedType() -> String {
        guard let type = type else { return "Unknown" }
        switch type {
        case "MOBL": return "Mobile"
        case "HOME": return "Home"
        case "BUS": return "Business"
        case "OTHR": return "Other"
        default: return "Unknown"      // Should default types be "Unknown" or "Other"
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case areaCode
        case phoneNumber
        case type
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        areaCode = try container.decodeIfPresent(String.self, forKey: .areaCode)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(areaCode, forKey: CodingKeys.areaCode)
        try container.encode(phoneNumber, forKey: CodingKeys.phoneNumber)
        try container.encode(type, forKey: CodingKeys.type)
    }

}
