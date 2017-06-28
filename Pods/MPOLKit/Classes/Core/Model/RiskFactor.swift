//
//  RiskFactor.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox

@objc(MPLRiskFactor)
open class RiskFactor: NSObject, Serialisable {
    
    open var type: String?
    open var riskFactorDescription: String?

    override public init() {

    }
    
    public required init(unboxer: Unboxer) throws {
        type = unboxer.unbox(key: "riskFactorType")
        riskFactorDescription = unboxer.unbox(key: "description")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }

}
