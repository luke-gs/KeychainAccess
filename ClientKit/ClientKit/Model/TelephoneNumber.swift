//
//  TelephoneNumber.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

@objc(MPLTelephoneNumber)
open class TelephoneNumber: NSObject, Serialisable {

    open let id: String
    
    open var suffix: String?
    open var cityCode: String?
    open var fullNumber: String?
    open var prefix: String?
    open var subscriber: String?
    open var areaCode: String?
    open var exchange: String?
    open var numberType: String?
    open var countryCode: String?
    
    
    public init(id: String) {
        self.id = id
        super.init()
    }
    
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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!

        super.init()

        suffix = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.suffix.rawValue) as String?
        cityCode = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.cityCode.rawValue) as String?
        fullNumber = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.fullNumber.rawValue) as String?
        prefix = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.prefix.rawValue) as String?
        subscriber = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.subscriber.rawValue) as String?
        areaCode = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.areaCode.rawValue) as String?
        exchange = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.exchange.rawValue) as String?
        numberType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.numberType.rawValue) as String?
        countryCode = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.countryCode.rawValue) as String?
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(TelephoneNumber.modalVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(suffix, forKey: CodingKey.suffix.rawValue)
        aCoder.encode(cityCode, forKey: CodingKey.cityCode.rawValue)
        aCoder.encode(fullNumber, forKey: CodingKey.fullNumber.rawValue)
        aCoder.encode(prefix, forKey: CodingKey.prefix.rawValue)
        aCoder.encode(subscriber, forKey: CodingKey.subscriber.rawValue)
        aCoder.encode(areaCode, forKey: CodingKey.areaCode.rawValue)
        aCoder.encode(exchange, forKey: CodingKey.exchange.rawValue)
        aCoder.encode(numberType, forKey: CodingKey.numberType.rawValue)
        aCoder.encode(countryCode, forKey: CodingKey.countryCode.rawValue)
    }
    
    open static var supportsSecureCoding: Bool { return true }
    open static var modalVersion: Int { return 0 }

    private enum CodingKey: String {
        case version
        case id
        case suffix
        case cityCode
        case fullNumber
        case prefix
        case subscriber
        case areaCode
        case exchange
        case numberType
        case countryCode
    }

}
