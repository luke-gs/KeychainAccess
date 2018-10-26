//
//  TelephoneNumber.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import PublicSafetyKit

@objc(MPLTelephoneNumber)
open class TelephoneNumber: DefaultSerialisable {

    // MARK: - Properties

    open var areaCode: String?
    open var cityCode: String?
    open var countryCode: String?
    open var exchange: String?
    open var fullNumber: String?
    open var id: String
    open var numberType: String?
    open var prefix: String?
    open var subscriber: String?
    open var suffix: String?

    public init(id: String) {
        self.id = id
        super.init()
    }

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id

        suffix = unboxer.unbox(key: "suffix")
        cityCode = unboxer.unbox(key: "cityCode")
        fullNumber = unboxer.unbox(key: "fullNumber")
        prefix = unboxer.unbox(key: "prefix")
        subscriber = unboxer.unbox(key: "subscriber")
        areaCode = unboxer.unbox(key: "areaCode")
        exchange = unboxer.unbox(key: "exchange")
        numberType = unboxer.unbox(key: "numberType")
        countryCode = unboxer.unbox(key: "countryCode")
        
        try super.init(unboxer: unboxer)
    }


    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case areaCode
        case cityCode
        case countryCode
        case exchange
        case fullNumber
        case id
        case numberType
        case prefix
        case subscriber
        case suffix
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        try super.init(from: decoder)
        guard !dataMigrated else { return }

        areaCode = try container.decodeIfPresent(String.self, forKey: .areaCode)
        cityCode = try container.decodeIfPresent(String.self, forKey: .cityCode)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        exchange = try container.decodeIfPresent(String.self, forKey: .exchange)
        fullNumber = try container.decodeIfPresent(String.self, forKey: .fullNumber)
        id = try container.decode(String.self, forKey: .id)
        numberType = try container.decodeIfPresent(String.self, forKey: .numberType)
        prefix = try container.decodeIfPresent(String.self, forKey: .prefix)
        subscriber = try container.decodeIfPresent(String.self, forKey: .subscriber)
        suffix = try container.decodeIfPresent(String.self, forKey: .suffix)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(areaCode, forKey: CodingKeys.areaCode)
        try container.encode(cityCode, forKey: CodingKeys.cityCode)
        try container.encode(countryCode, forKey: CodingKeys.countryCode)
        try container.encode(exchange, forKey: CodingKeys.exchange)
        try container.encode(fullNumber, forKey: CodingKeys.fullNumber)
        try container.encode(id, forKey: CodingKeys.id)
        try container.encode(numberType, forKey: CodingKeys.numberType)
        try container.encode(prefix, forKey: CodingKeys.prefix)
        try container.encode(subscriber, forKey: CodingKeys.subscriber)
        try container.encode(suffix, forKey: CodingKeys.suffix)
    }

}
