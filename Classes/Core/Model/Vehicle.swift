//
//  Vehicle.swift
//  MPOL
//
//  Created by Herli Halim on 8/5/17.
//
//

import Unbox

@objc(MPLVehicle)
open class Vehicle: Entity {
    
    open override class var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }
    
    open override var summary: String {
        return registration ?? NSLocalizedString("Registration Unknown", comment: "")
    }
    
    open var bodyType: String?
    
    open var primaryColor: String?
    open var secondaryColor: String?

    open var registration: String?
    open var registrationEffectiveFromDate: Date?
    open var registrationEffectiveToDate: Date?
    open var registrationCategory: String?
    open var registrationState: String?
    open var registrationPurposeOfUse: String?
    
    open var vin: String?
    open var engineNumber: String?
    open var engineCapacity: String?
    open var enginePower: String?
    open var cylinders: String?
    open var chassisNumber: String?
    
    open var make: String?
    open var model: String?
    open var year: Int?
    open var seatingCapacity: Int?
    open var weight: Int?
    open var speedLimiter: Bool?
    open var speedLimiterSetting: Int?
    open var axles: Int?
    open var vehicleDescription: String?
    
    public required init(id: String) {
        super.init(id: id)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        bodyType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.bodyType.rawValue) as String?
        primaryColor = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.primaryColor.rawValue) as String?
        
        fatalError("Not implemented correctly yet")
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        fatalError("Not implemented correctly yet")
    }

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    // MARK: - Unboxable
    public required init(unboxer: Unboxer) throws {

        do {
            try super.init(unboxer: unboxer)
        }
        
        registration = unboxer.unbox(key: "registration")
        registrationState = unboxer.unbox(key: "registrationState")
        registrationCategory = unboxer.unbox(key: "registrationCategory")
        registrationPurposeOfUse = unboxer.unbox(key: "registrationPurposeOfUse")
        registrationEffectiveFromDate = unboxer.unbox(key: "registrationEffectiveDate", formatter: Vehicle.dateTransformer)
        registrationEffectiveToDate = unboxer.unbox(key: "registrationExpiryDate", formatter: Vehicle.dateTransformer)

        bodyType = unboxer.unbox(key: "bodyType")
        primaryColor = unboxer.unbox(key: "primaryColour")
        secondaryColor = unboxer.unbox(key: "secondaryColor")
        
        vin = unboxer.unbox(key: "vin")
        engineCapacity = unboxer.unbox(key: "engineCapacity")
        enginePower = unboxer.unbox(key: "enginePower")
        engineNumber = unboxer.unbox(key: "engineNumber")
        
        chassisNumber = unboxer.unbox(key: "chassisNumber")
        
        make = unboxer.unbox(key: "make")
        model = unboxer.unbox(key: "model")
        year = unboxer.unbox(key: "year")
        seatingCapacity = unboxer.unbox(key: "seatingCapacity")
        weight = unboxer.unbox(key: "weight")
        
        speedLimiter = unboxer.unbox(key: "speedLimiter")
        speedLimiterSetting = unboxer.unbox(key: "speedLimiterSetting")
        
        cylinders = unboxer.unbox(key: "cylinders")
        axles = unboxer.unbox(key: "axles")
        
        vehicleDescription = unboxer.unbox(key: "vehicleDescription")
    }
    
}

private enum CodingKey: String {
    case bodyType
    
    case primaryColor
    case secondaryColor
    
    case registration
    case registrationEffectiveFromDate
    case registrationEffectiveToDate
    case registrationCategory
    case registrationState
    case registrationPurposeOfUse
    
    case vin
    case engineNumber
    case engineCapacity
    case enginePower
    case cylinders
    case chassisNumber
    
    case make
    case model
    case year
    case seatingCapacity
    case weight
    case speedLimiter
    case speedLimiterSetting
    case axles
    case vehicleDescription

}
