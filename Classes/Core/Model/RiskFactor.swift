//
//  RiskFactor.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox

open class RiskFactor: NSObject, Serialisable {
    
    open var type: String?
    open var riskFactorDescription: String?
    
    public required init(unboxer: Unboxer) throws {
        type = unboxer.unbox(key: "riskFactorType")
        riskFactorDescription = unboxer.unbox(key: "description")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }

}
