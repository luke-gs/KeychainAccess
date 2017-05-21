//
//  TelephoneNumber.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

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
        fatalError("Not implemented yet")
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
    
}
