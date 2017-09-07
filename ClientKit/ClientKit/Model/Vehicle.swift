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
    case VehicleType = "VehicleType"
    case Registration = "Registration"
    case PlateType = "PlateType"
    case Vin = "Vin"
    case EngineNumber = "EngineNumber"
    case ChassisNumber = "ChassisNumber"
    case Year = "Year"
    case Make = "Make"
    case Model = "Model"
    case Variant = "Variant"
    case BodyType = "BodyType"
    case PrimaryColor = "PrimaryColor"
    case SecondaryColor = "SecondaryColor"
    case Wheels = "Wheels"
    case Axles = "Axles"
    case EngineCapacity = "EngineCapacity"
    case EnginePower = "EnginePower"
    case Cylinders = "Cylinders"
    case Transmission = "Transmission"
    case RegistrationStatus = "RegistrationStatus"
    case RegistrationCategory = "RegistrationCategory"
    case RegistrationEffectiveDate = "RegistrationEffectiveDate"
    case RegistrationExpiryDate = "RegistrationExpiryDate"
    case RegistrationState = "RegistrationState"
    case RegistrationPurposeOfUse = "RegistrationPurposeOfUse"
    case IsStolen = "IsStolen"
    case SeatingCapacity = "SeatingCapacity"
    case Weight = "Weight"
    case SpeedLimiter = "SpeedLimiter"
    case SpeedLimiterSetting = "SpeedLimiterSetting"
    case InterlockDevice = "InterlockDevice"
    case VehicleDescription = "VehicleDescription"
    case Remarks = "Remarks"
    case IsPlate = "IsPlate"
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
        vehicleType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.VehicleType.rawValue) as String?
        registration = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Registration.rawValue) as String?
        plateType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.PlateType.rawValue) as String?
        vin = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Vin.rawValue) as String?
        engineNumber = aDecoder.decodeObject(of: NSString.self, forKey: Coding.EngineNumber.rawValue) as String?
        chassisNumber = aDecoder.decodeObject(of: NSString.self, forKey: Coding.ChassisNumber.rawValue) as String?
        year = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Year.rawValue) as String?
        make = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Make.rawValue) as String?
        model = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Model.rawValue) as String?
        variant = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Variant.rawValue) as String?
        bodyType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.BodyType.rawValue) as String?
        primaryColor = aDecoder.decodeObject(of: NSString.self, forKey: Coding.PrimaryColor.rawValue) as String?
        secondaryColor = aDecoder.decodeObject(of: NSString.self, forKey: Coding.SecondaryColor.rawValue) as String?
        wheels = (aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.Wheels.rawValue))?.intValue
        axles = (aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.Axles.rawValue))?.intValue
        engineCapacity = aDecoder.decodeObject(of: NSString.self, forKey: Coding.EngineCapacity.rawValue) as String?
        enginePower = aDecoder.decodeObject(of: NSString.self, forKey: Coding.EnginePower.rawValue) as String?
        cylinders = (aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.Cylinders.rawValue))?.intValue
        transmission = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Transmission.rawValue) as String?
        registrationStatus = aDecoder.decodeObject(of: NSString.self, forKey: Coding.RegistrationStatus.rawValue) as String?
        registrationCategory = aDecoder.decodeObject(of: NSString.self, forKey: Coding.RegistrationCategory.rawValue) as String?
        registrationEffectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.RegistrationEffectiveDate.rawValue) as Date?
        registrationExpiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.RegistrationExpiryDate.rawValue) as Date?
        registrationState = aDecoder.decodeObject(of: NSString.self, forKey: Coding.RegistrationState.rawValue) as String?
        registrationPurposeOfUse = aDecoder.decodeObject(of: NSString.self, forKey: Coding.RegistrationPurposeOfUse.rawValue) as String?
        isStolen = aDecoder.decodeObject(forKey: Coding.IsStolen.rawValue) as! Bool?
        seatingCapacity = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.SeatingCapacity.rawValue)?.intValue
        weight = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.Weight.rawValue)?.intValue
        speedLimiter = aDecoder.decodeObject(forKey: Coding.SpeedLimiter.rawValue) as! Bool?
        speedLimiterSetting = aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.SpeedLimiterSetting.rawValue)?.intValue
        interlockDevice = aDecoder.decodeObject(forKey: Coding.InterlockDevice.rawValue) as! Bool?
        vehicleDescription = aDecoder.decodeObject(of: NSString.self, forKey: Coding.VehicleDescription.rawValue) as String?
        remarks = aDecoder.decodeObject(of: NSString.self, forKey: Coding.Remarks.rawValue) as String?
        isPlate = aDecoder.decodeObject(forKey: Coding.IsPlate.rawValue) as! Bool?
    }

    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(vehicleType, forKey: Coding.VehicleType.rawValue)
        aCoder.encode(registration, forKey: Coding.Registration.rawValue)
        aCoder.encode(plateType, forKey: Coding.PlateType.rawValue)
        aCoder.encode(vin, forKey: Coding.Vin.rawValue)
        aCoder.encode(engineNumber, forKey: Coding.EngineNumber.rawValue)
        aCoder.encode(chassisNumber, forKey: Coding.ChassisNumber.rawValue)
        aCoder.encode(year, forKey: Coding.Year.rawValue)
        aCoder.encode(make, forKey: Coding.Make.rawValue)
        aCoder.encode(model, forKey: Coding.Model.rawValue)
        aCoder.encode(variant, forKey: Coding.Variant.rawValue)
        aCoder.encode(bodyType, forKey: Coding.BodyType.rawValue)
        aCoder.encode(primaryColor, forKey: Coding.PrimaryColor.rawValue)
        aCoder.encode(secondaryColor, forKey: Coding.SecondaryColor.rawValue)
        aCoder.encode(wheels, forKey: Coding.Wheels.rawValue)
        aCoder.encode(axles, forKey: Coding.Axles.rawValue)
        aCoder.encode(engineCapacity, forKey: Coding.EngineCapacity.rawValue)
        aCoder.encode(enginePower, forKey: Coding.EnginePower.rawValue)
        aCoder.encode(cylinders, forKey: Coding.Cylinders.rawValue)
        aCoder.encode(transmission, forKey: Coding.Transmission.rawValue)
        aCoder.encode(registrationStatus, forKey: Coding.RegistrationStatus.rawValue)
        aCoder.encode(registrationCategory, forKey: Coding.RegistrationCategory.rawValue)
        aCoder.encode(registrationEffectiveDate, forKey: Coding.RegistrationEffectiveDate.rawValue)
        aCoder.encode(registrationExpiryDate, forKey: Coding.RegistrationExpiryDate.rawValue)
        aCoder.encode(registrationState, forKey: Coding.RegistrationState.rawValue)
        aCoder.encode(registrationPurposeOfUse, forKey: Coding.RegistrationPurposeOfUse.rawValue)
        aCoder.encode(isStolen, forKey: Coding.IsStolen.rawValue)
        aCoder.encode(seatingCapacity, forKey: Coding.SeatingCapacity.rawValue)
        aCoder.encode(weight, forKey: Coding.Weight.rawValue)
        aCoder.encode(speedLimiter, forKey: Coding.SpeedLimiter.rawValue)
        aCoder.encode(speedLimiterSetting, forKey: Coding.SpeedLimiterSetting.rawValue)
        aCoder.encode(interlockDevice, forKey: Coding.InterlockDevice.rawValue)
        aCoder.encode(vehicleDescription, forKey: Coding.VehicleDescription.rawValue)
        aCoder.encode(remarks, forKey: Coding.Remarks.rawValue)
        aCoder.encode(isPlate, forKey: Coding.IsPlate.rawValue)
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
