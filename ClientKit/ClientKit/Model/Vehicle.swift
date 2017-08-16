//
//  Vehicle.swift
//  MPOL
//
//  Created by Herli Halim on 8/5/17.
//
//

import MPOLKit
import Unbox

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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        
//        bodyType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.bodyType.rawValue) as String?
//        primaryColor = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.primaryColor.rawValue) as String?
//        
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
    
    // TEMPORARY
//    open override func thumbnailImage(ofSize size: EntityThumbnailView.ThumbnailSize) -> (UIImage, UIViewContentMode)? {
//        let imageName: String
//        switch size {
//        case .small:
//            imageName = "iconEntityAutomotiveFilled"
//        case .medium:
//            imageName = "iconEntityAutomotive48Filled"
//        case .large:
//            imageName = "iconEntityAutomotive96Filled"
//        }
//        
//        if let image = UIImage(named: imageName, in: .mpolKit, compatibleWith: nil) {
//            return (image, .center)
//        }
//        
//        return super.thumbnailImage(ofSize: size)
//    }
    
}

//private enum CodingKey: String {
//    case bodyType
//    
//    case primaryColor
//    case secondaryColor
//    
//    case registration
//    case registrationEffectiveFromDate
//    case registrationEffectiveToDate
//    case registrationCategory
//    case registrationState
//    case registrationPurposeOfUse
//    
//    case vin
//    case engineNumber
//    case engineCapacity
//    case enginePower
//    case cylinders
//    case chassisNumber
//    
//    case make
//    case model
//    case year
//    case seatingCapacity
//    case weight
//    case speedLimiter
//    case speedLimiterSetting
//    case axles
//    case vehicleDescription
//
//}
