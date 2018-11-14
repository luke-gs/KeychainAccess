//
//  Vehicle.swift
//  MPOL
//
//  Created by Herli Halim on 8/5/17.
//
//

import PublicSafetyKit
import Unbox

@objc(MPLVehicle)
open class Vehicle: Entity {

    // MARK: - Class

    override open class var serverTypeRepresentation: String {
        return "vehicle"
    }

    open override class var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }

    public required override init(id: String) {
        super.init(id: id)
    }

    // MARK: - Properties

    public var axles: Int?
    public var bodyType: String?
    public var chassisNumber: String?
    public var cylinders: Int?
    public var engineCapacity: String?
    public var engineNumber: String?
    public var enginePower: String?
    public var interlockDevice: Bool?
    public var isPlate: Bool?
    public var isStolen: Bool?
    public var make: String?
    public var model: String?
    public var plateType: String?
    public var primaryColor: String?
    public var registration: String?
    public var registrationCategory: String?
    public var registrationEffectiveDate: Date?
    public var registrationExpiryDate: Date?
    public var registrationPurposeOfUse: String?
    public var registrationState: String?
    public var registrationStatus: String?
    public var remarks: String?
    public var seatingCapacity: Int?
    public var secondaryColor: String?
    public var speedLimiter: Bool?
    public var speedLimiterSetting: Int?
    public var transmission: String?
    public var variant: String?
    public var vehicleDescription: String?
    public var vehicleType: String?
    public var vin: String?
    public var weight: Int?
    public var wheels: Int?
    public var year: String?
    public var tare: String?
    public var grossVehicleMass: String?
    public var fuelType: String?


    // MARK: - Calculated

    open override var summary: String {
        return registration ?? NSLocalizedString("Registration Unknown", comment: "")
    }

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    // MARK: - Unboxable
    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)

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

        tare = unboxer.unbox(key: "tare")
        grossVehicleMass = unboxer.unbox(key: "grossVehicleMass")
        fuelType = unboxer.unbox(key: "fuelType")

    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case axles
        case bodyType
        case chassisNumber
        case cylinders
        case engineCapacity
        case engineNumber
        case enginePower
        case interlockDevice
        case isPlate
        case isStolen
        case make
        case model
        case plateType
        case primaryColor
        case registration
        case registrationCategory
        case registrationEffectiveDate
        case registrationExpiryDate
        case registrationPurposeOfUse
        case registrationState
        case registrationStatus
        case remarks
        case seatingCapacity
        case secondaryColor
        case speedLimiter
        case speedLimiterSetting
        case transmission
        case variant
        case vehicleDescription
        case vehicleType
        case vin
        case weight
        case wheels
        case year
        case tare
        case grossVehicleMass
        case fuelType
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        axles = try container.decodeIfPresent(Int.self, forKey: .axles)
        bodyType = try container.decodeIfPresent(String.self, forKey: .bodyType)
        chassisNumber = try container.decodeIfPresent(String.self, forKey: .chassisNumber)
        cylinders = try container.decodeIfPresent(Int.self, forKey: .cylinders)
        engineCapacity = try container.decodeIfPresent(String.self, forKey: .engineCapacity)
        engineNumber = try container.decodeIfPresent(String.self, forKey: .engineNumber)
        enginePower = try container.decodeIfPresent(String.self, forKey: .enginePower)
        interlockDevice = try container.decodeIfPresent(Bool.self, forKey: .interlockDevice)
        isPlate = try container.decodeIfPresent(Bool.self, forKey: .isPlate)
        isStolen = try container.decodeIfPresent(Bool.self, forKey: .isStolen)
        make = try container.decodeIfPresent(String.self, forKey: .make)
        model = try container.decodeIfPresent(String.self, forKey: .model)
        plateType = try container.decodeIfPresent(String.self, forKey: .plateType)
        primaryColor = try container.decodeIfPresent(String.self, forKey: .primaryColor)
        registration = try container.decodeIfPresent(String.self, forKey: .registration)
        registrationCategory = try container.decodeIfPresent(String.self, forKey: .registrationCategory)
        registrationEffectiveDate = try container.decodeIfPresent(Date.self, forKey: .registrationEffectiveDate)
        registrationExpiryDate = try container.decodeIfPresent(Date.self, forKey: .registrationExpiryDate)
        registrationPurposeOfUse = try container.decodeIfPresent(String.self, forKey: .registrationPurposeOfUse)
        registrationState = try container.decodeIfPresent(String.self, forKey: .registrationState)
        registrationStatus = try container.decodeIfPresent(String.self, forKey: .registrationStatus)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        seatingCapacity = try container.decodeIfPresent(Int.self, forKey: .seatingCapacity)
        secondaryColor = try container.decodeIfPresent(String.self, forKey: .secondaryColor)
        speedLimiter = try container.decodeIfPresent(Bool.self, forKey: .speedLimiter)
        speedLimiterSetting = try container.decodeIfPresent(Int.self, forKey: .speedLimiterSetting)
        transmission = try container.decodeIfPresent(String.self, forKey: .transmission)
        variant = try container.decodeIfPresent(String.self, forKey: .variant)
        vehicleDescription = try container.decodeIfPresent(String.self, forKey: .vehicleDescription)
        vehicleType = try container.decodeIfPresent(String.self, forKey: .vehicleType)
        vin = try container.decodeIfPresent(String.self, forKey: .vin)
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        wheels = try container.decodeIfPresent(Int.self, forKey: .wheels)
        year = try container.decodeIfPresent(String.self, forKey: .year)

        tare = try container.decodeIfPresent(String.self, forKey: .tare)
        grossVehicleMass = try container.decodeIfPresent(String.self, forKey: .grossVehicleMass)
        fuelType = try container.decodeIfPresent(String.self, forKey: .fuelType)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(axles, forKey: CodingKeys.axles)
        try container.encode(bodyType, forKey: CodingKeys.bodyType)
        try container.encode(chassisNumber, forKey: CodingKeys.chassisNumber)
        try container.encode(cylinders, forKey: CodingKeys.cylinders)
        try container.encode(engineCapacity, forKey: CodingKeys.engineCapacity)
        try container.encode(engineNumber, forKey: CodingKeys.engineNumber)
        try container.encode(enginePower, forKey: CodingKeys.enginePower)
        try container.encode(interlockDevice, forKey: CodingKeys.interlockDevice)
        try container.encode(isPlate, forKey: CodingKeys.isPlate)
        try container.encode(isStolen, forKey: CodingKeys.isStolen)
        try container.encode(make, forKey: CodingKeys.make)
        try container.encode(model, forKey: CodingKeys.model)
        try container.encode(plateType, forKey: CodingKeys.plateType)
        try container.encode(primaryColor, forKey: CodingKeys.primaryColor)
        try container.encode(registration, forKey: CodingKeys.registration)
        try container.encode(registrationCategory, forKey: CodingKeys.registrationCategory)
        try container.encode(registrationEffectiveDate, forKey: CodingKeys.registrationEffectiveDate)
        try container.encode(registrationExpiryDate, forKey: CodingKeys.registrationExpiryDate)
        try container.encode(registrationPurposeOfUse, forKey: CodingKeys.registrationPurposeOfUse)
        try container.encode(registrationState, forKey: CodingKeys.registrationState)
        try container.encode(registrationStatus, forKey: CodingKeys.registrationStatus)
        try container.encode(remarks, forKey: CodingKeys.remarks)
        try container.encode(seatingCapacity, forKey: CodingKeys.seatingCapacity)
        try container.encode(secondaryColor, forKey: CodingKeys.secondaryColor)
        try container.encode(speedLimiter, forKey: CodingKeys.speedLimiter)
        try container.encode(speedLimiterSetting, forKey: CodingKeys.speedLimiterSetting)
        try container.encode(transmission, forKey: CodingKeys.transmission)
        try container.encode(variant, forKey: CodingKeys.variant)
        try container.encode(vehicleDescription, forKey: CodingKeys.vehicleDescription)
        try container.encode(vehicleType, forKey: CodingKeys.vehicleType)
        try container.encode(vin, forKey: CodingKeys.vin)
        try container.encode(weight, forKey: CodingKeys.weight)
        try container.encode(wheels, forKey: CodingKeys.wheels)
        try container.encode(year, forKey: CodingKeys.year)
        try container.encode(tare, forKey: CodingKeys.tare)
        try container.encode(grossVehicleMass, forKey: CodingKeys.grossVehicleMass)
        try container.encode(fuelType, forKey: CodingKeys.fuelType)
    }

}
