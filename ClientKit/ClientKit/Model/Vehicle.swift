//
//  Vehicle.swift
//  MPOL
//
//  Created by Herli Halim on 8/5/17.
//
//

import MPOLKit
import Unbox

private enum Coding: String {
    case vehicleType = "vehicleType"
    case registration = "registration"
    case plateType = "plateType"
    case vin = "vin"
    case engineNumber = "engineNumber"
    case chassisNumber = "chassisNumber"
    case year = "year"
    case make = "make"
    case model = "model"
    case variant = "variant"
    case bodyType = "bodyType"
    case primaryColor = "primaryColor"
    case secondaryColor = "secondaryColor"
    case wheels = "wheels"
    case axles = "axles"
    case engineCapacity = "engineCapacity"
    case enginePower = "enginePower"
    case cylinders = "cylinders"
    case transmission = "transmission"
    case registrationStatus = "registrationStatus"
    case registrationCategory = "registrationCategory"
    case registrationEffectiveDate = "registrationEffectiveDate"
    case registrationExpiryDate = "registrationExpiryDate"
    case registrationState = "registrationState"
    case registrationPurposeOfUse = "registrationPurposeOfUse"
    case isStolen = "isStolen"
    case seatingCapacity = "seatingCapacity"
    case weight = "weight"
    case speedLimiter = "speedLimiter"
    case speedLimiterSetting = "speedLimiterSetting"
    case interlockDevice = "interlockDevice"
    case vehicleDescription = "vehicleDescription"
    case remarks = "remarks"
    case isPlate = "isPlate"
}

@objc(MPLVehicle)
open class Vehicle: Entity {

    override open class var serverTypeRepresentation: String {
        return "vehicle"
    }
    
    open override class var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }
    
    open override var summary: String {
        return registration ?? NSLocalizedString("Registration Unknown", comment: "")
    }
    
    open var vehicleType: String?
    open var registration: String?
    open var plateType: String?
    
    open var vin: String?
    open var engineNumber: String?
    open var chassisNumber: String?
    
    open var year: String?
    open var make: String?
    open var model: String?
    open var variant: String?
    open var bodyType: String?
    
    open var primaryColor: String?
    open var secondaryColor: String?
    
    open var wheels: Int?
    open var axles: Int?
    open var engineCapacity: String?
    open var enginePower: String?
    open var cylinders: Int?
    open var transmission: String?
    
    open var registrationStatus: String?
    open var registrationCategory: String?
    open var registrationEffectiveDate: Date?
    open var registrationExpiryDate: Date?
    open var registrationState: String?
    open var registrationPurposeOfUse: String?
    
    open var isStolen: Bool?
    open var seatingCapacity: Int?
    open var weight: Int?
    open var speedLimiter: Bool?
    open var speedLimiterSetting: Int?
    open var interlockDevice: Bool?
    open var vehicleDescription: String?
    open var remarks: String?
    open var isPlate: Bool?
    
    public required override init(id: String) {
        super.init(id: id)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        vehicleType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.vehicleType.rawValue) as String?
        registration = aDecoder.decodeObject(of: NSString.self, forKey: Coding.registration.rawValue) as String?
        plateType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.plateType.rawValue) as String?
        vin = aDecoder.decodeObject(of: NSString.self, forKey: Coding.vin.rawValue) as String?
        engineNumber = aDecoder.decodeObject(of: NSString.self, forKey: Coding.engineNumber.rawValue) as String?
        chassisNumber = aDecoder.decodeObject(of: NSString.self, forKey: Coding.chassisNumber.rawValue) as String?
        year = aDecoder.decodeObject(of: NSString.self, forKey: Coding.year.rawValue) as String?
        make = aDecoder.decodeObject(of: NSString.self, forKey: Coding.make.rawValue) as String?
        model = aDecoder.decodeObject(of: NSString.self, forKey: Coding.model.rawValue) as String?
        variant = aDecoder.decodeObject(of: NSString.self, forKey: Coding.variant.rawValue) as String?
        bodyType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.bodyType.rawValue) as String?
        primaryColor = aDecoder.decodeObject(of: NSString.self, forKey: Coding.primaryColor.rawValue) as String?
        secondaryColor = aDecoder.decodeObject(of: NSString.self, forKey: Coding.secondaryColor.rawValue) as String?
        wheels = (aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.wheels.rawValue))?.intValue
        axles = (aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.axles.rawValue))?.intValue
        engineCapacity = aDecoder.decodeObject(of: NSString.self, forKey: Coding.engineCapacity.rawValue) as String?
        enginePower = aDecoder.decodeObject(of: NSString.self, forKey: Coding.enginePower.rawValue) as String?
        cylinders = (aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.cylinders.rawValue))?.intValue
        transmission = aDecoder.decodeObject(of: NSString.self, forKey: Coding.transmission.rawValue) as String?
        registrationStatus = aDecoder.decodeObject(of: NSString.self, forKey: Coding.registrationStatus.rawValue) as String?
        registrationCategory = aDecoder.decodeObject(of: NSString.self, forKey: Coding.registrationCategory.rawValue) as String?
        registrationEffectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.registrationEffectiveDate.rawValue) as Date?
        registrationExpiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.registrationExpiryDate.rawValue) as Date?
        registrationState = aDecoder.decodeObject(of: NSString.self, forKey: Coding.registrationState.rawValue) as String?
        registrationPurposeOfUse = aDecoder.decodeObject(of: NSString.self, forKey: Coding.registrationPurposeOfUse.rawValue) as String?
        isStolen = aDecoder.decodeObject(forKey: Coding.isStolen.rawValue) as! Bool?
        seatingCapacity = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.seatingCapacity.rawValue)?.intValue
        weight = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.weight.rawValue)?.intValue
        speedLimiter = aDecoder.decodeObject(forKey: Coding.speedLimiter.rawValue) as! Bool?
        speedLimiterSetting = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.speedLimiterSetting.rawValue)?.intValue
        interlockDevice = aDecoder.decodeObject(forKey: Coding.interlockDevice.rawValue) as! Bool?
        vehicleDescription = aDecoder.decodeObject(of: NSString.self, forKey: Coding.vehicleDescription.rawValue) as String?
        remarks = aDecoder.decodeObject(of: NSString.self, forKey: Coding.remarks.rawValue) as String?
        isPlate = aDecoder.decodeObject(forKey: Coding.isPlate.rawValue) as! Bool?
    }

    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(vehicleType, forKey: Coding.vehicleType.rawValue)
        aCoder.encode(registration, forKey: Coding.registration.rawValue)
        aCoder.encode(plateType, forKey: Coding.plateType.rawValue)
        aCoder.encode(vin, forKey: Coding.vin.rawValue)
        aCoder.encode(engineNumber, forKey: Coding.engineNumber.rawValue)
        aCoder.encode(chassisNumber, forKey: Coding.chassisNumber.rawValue)
        aCoder.encode(year, forKey: Coding.year.rawValue)
        aCoder.encode(make, forKey: Coding.make.rawValue)
        aCoder.encode(model, forKey: Coding.model.rawValue)
        aCoder.encode(variant, forKey: Coding.variant.rawValue)
        aCoder.encode(bodyType, forKey: Coding.bodyType.rawValue)
        aCoder.encode(primaryColor, forKey: Coding.primaryColor.rawValue)
        aCoder.encode(secondaryColor, forKey: Coding.secondaryColor.rawValue)
        aCoder.encode(wheels, forKey: Coding.wheels.rawValue)
        aCoder.encode(axles, forKey: Coding.axles.rawValue)
        aCoder.encode(engineCapacity, forKey: Coding.engineCapacity.rawValue)
        aCoder.encode(enginePower, forKey: Coding.enginePower.rawValue)
        aCoder.encode(cylinders, forKey: Coding.cylinders.rawValue)
        aCoder.encode(transmission, forKey: Coding.transmission.rawValue)
        aCoder.encode(registrationStatus, forKey: Coding.registrationStatus.rawValue)
        aCoder.encode(registrationCategory, forKey: Coding.registrationCategory.rawValue)
        aCoder.encode(registrationEffectiveDate, forKey: Coding.registrationEffectiveDate.rawValue)
        aCoder.encode(registrationExpiryDate, forKey: Coding.registrationExpiryDate.rawValue)
        aCoder.encode(registrationState, forKey: Coding.registrationState.rawValue)
        aCoder.encode(registrationPurposeOfUse, forKey: Coding.registrationPurposeOfUse.rawValue)
        aCoder.encode(isStolen, forKey: Coding.isStolen.rawValue)
        aCoder.encode(seatingCapacity, forKey: Coding.seatingCapacity.rawValue)
        aCoder.encode(weight, forKey: Coding.weight.rawValue)
        aCoder.encode(speedLimiter, forKey: Coding.speedLimiter.rawValue)
        aCoder.encode(speedLimiterSetting, forKey: Coding.speedLimiterSetting.rawValue)
        aCoder.encode(interlockDevice, forKey: Coding.interlockDevice.rawValue)
        aCoder.encode(vehicleDescription, forKey: Coding.vehicleDescription.rawValue)
        aCoder.encode(remarks, forKey: Coding.remarks.rawValue)
        aCoder.encode(isPlate, forKey: Coding.isPlate.rawValue)
    }

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    // MARK: - Unboxable
    public required init(unboxer: Unboxer) throws {

        do {
            try super.init(unboxer: unboxer)
        }
        
        vehicleType = unboxer.unbox(key: "vehicleType")
        registration = unboxer.unbox(key: "plateNumber")
        plateType = unboxer.unbox(key: "plateType")
        vin = unboxer.unbox(key: "vin")
        
        engineNumber = unboxer.unbox(key: "engineNumber")
        chassisNumber = unboxer.unbox(key: "chassisNumber")
        
        year = unboxer.unbox(key: "year")
        make = unboxer.unbox(key: "make")
        model = unboxer.unbox(key: "model")
        variant = unboxer.unbox(key: "variant")
        bodyType = unboxer.unbox(key: "bodyType")
        
        primaryColor = unboxer.unbox(key: "primaryColour")
        secondaryColor = unboxer.unbox(key: "secondaryColor")
        
        wheels = unboxer.unbox(key: "wheels")
        axles  = unboxer.unbox(key: "axles")
        engineCapacity = unboxer.unbox(key: "engineCapacity")
        enginePower    = unboxer.unbox(key: "enginePower")
        cylinders = unboxer.unbox(key: "cylinders")
        transmission = unboxer.unbox(key: "transmission")
        
        registrationStatus = unboxer.unbox(key: "registrationStatus")
        registrationCategory = unboxer.unbox(key: "registrationCategory")
        registrationEffectiveDate = unboxer.unbox(key: "registrationEffectiveDate", formatter: Vehicle.dateTransformer)
        registrationExpiryDate = unboxer.unbox(key: "registrationExpiryDate", formatter: Vehicle.dateTransformer)
        registrationState = unboxer.unbox(key: "registrationState")
        registrationPurposeOfUse = unboxer.unbox(key: "registrationPurposeOfUse")
        
        isStolen = unboxer.unbox(key: "isStolen")
        seatingCapacity = unboxer.unbox(key: "seatingCapacity")
        weight = unboxer.unbox(key: "weight")
        speedLimiter = unboxer.unbox(key: "speedLimiter")
        speedLimiterSetting = unboxer.unbox(key: "speedLimiterSetting")
        interlockDevice = unboxer.unbox(key: "interlockDevice")
        vehicleDescription = unboxer.unbox(key: "description")
        remarks = unboxer.unbox(key: "remarks")
        isPlate = unboxer.unbox(key: "isPlate")
    }
}
