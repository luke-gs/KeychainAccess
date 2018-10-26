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
open class PhoneNumber: DefaultSerialisable {

    // MARK: - Properties

    open var areaCode: String?
    open var phoneNumber: String?
    open var type: String?
    open var id: String

    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {

        if let id: String = unboxer.unbox(key: "id") {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }

        type = unboxer.unbox(key: "type")
        areaCode = unboxer.unbox(key: "areaCode")
        phoneNumber = unboxer.unbox(key: "phoneNumber")

        super.init()
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
        case id
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        try super.init(from: decoder)
        guard !dataMigrated else { return }

        areaCode = try container.decodeIfPresent(String.self, forKey: .areaCode)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        id = try container.decode(String.self, forKey: .id)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(areaCode, forKey: CodingKeys.areaCode)
        try container.encode(phoneNumber, forKey: CodingKeys.phoneNumber)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(id, forKey: CodingKeys.id)
    }

}
