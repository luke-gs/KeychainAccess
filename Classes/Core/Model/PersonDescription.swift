//
//  PersonDescription.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Unbox

@objc(MPLPersonDescription)
open class PersonDescription: NSObject, Serialisable {
    
    open var id: String
    open var reportDate: Date?
    
    open var religion: String?
    open var indigenousAustralianStatus: String?
    open var occupation: String?
    open var complexion: String?
    open var nationality: String?
    open var teeth: String?
    open var facialHair: String?
    open var build: String?
    open var weight: String?
    open var hairColour: String?
    open var hairLength: String?
    open var speech: String?
    open var maritalStatus: String?
    open var eyeColour: String?
    open var height: Int?
    open var glasses: String?
    
    open static var supportsSecureCoding: Bool { return true }
    
    public required init(unboxer: Unboxer) throws {
//        guard let id: String = unboxer.unbox(key: "id") else {
//            throw ParsingError.missingRequiredField
//        }
//        self.id = id
        
        id = unboxer.unbox(key: "id") ?? UUID().uuidString
        
        religion = unboxer.unbox(key: "religion")
        indigenousAustralianStatus = unboxer.unbox(key: "indigenousAustralianStatus")
        occupation = unboxer.unbox(key: "occupation")
        complexion = unboxer.unbox(key: "complexion")
        nationality = unboxer.unbox(key: "nationality")
        teeth = unboxer.unbox(key: "teeth")
        facialHair = unboxer.unbox(key: "facialHair")
        build = unboxer.unbox(key: "build")
        weight = unboxer.unbox(key: "weight")
        hairColour = unboxer.unbox(key: "hairColour")
        hairLength = unboxer.unbox(key: "hairLength")
        speech = unboxer.unbox(key: "speech")
        maritalStatus = unboxer.unbox(key: "maritalStatus")
        eyeColour = unboxer.unbox(key: "eyeColour")
        height = unboxer.unbox(key: "height")
        glasses = unboxer.unbox(key: "glasses")
        reportDate = unboxer.unbox(key: "reportDate", formatter: ISO8601DateTransformer.shared)
        
        super.init()
    }
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    public func encode(with aCoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    public func formatted() -> String? {
        var initialString = ""
        if let height = height {
            initialString = "\(height) cm "
        }
        if let build = build?.ifNotEmpty() {
            initialString += build.localizedLowercase
            initialString += " "
        }
        if let weight = weight?.ifNotEmpty() {
            initialString += "\(weight) kg "
        }
        if let complexion = complexion?.ifNotEmpty() {
            initialString += complexion.localizedLowercase
            initialString += " "
        }
        if let indigenousStatus = indigenousAustralianStatus?.ifNotEmpty() {
            initialString += indigenousStatus.localizedLowercase
            initialString += " "
        } else if let nationality = nationality?.ifNotEmpty() {
            initialString += nationality.localizedLowercase
            initialString += " "
        }
        
        initialString = initialString.trimmingCharacters(in: .whitespaces)
        
        var formattedComponents: [String] = []
        
        if initialString.isEmpty == false {
            formattedComponents.append(initialString)
        }
        
        var hair = ""
        if let hairLength = hairLength?.ifNotEmpty() {
            hair += hairLength.localizedLowercase
            hair += " "
        }
        if let hairColour = hairColour?.ifNotEmpty() {
            hair += hairColour.localizedLowercase
            hair += " "
        }
        if hair.isEmpty == false {
            hair += "hair"
            formattedComponents.append(hair)
        }
        if let eyeColour = eyeColour?.ifNotEmpty() {
            formattedComponents.append(eyeColour.localizedLowercase + " eyes")
        }
        if let glasses = glasses?.ifNotEmpty() {
            formattedComponents.append(glasses.localizedLowercase + " glasses")
        }
        if let facialHair = facialHair?.ifNotEmpty() {
            formattedComponents.append(facialHair.localizedLowercase + " facial hair")
        }
        if let teeth = teeth?.ifNotEmpty() {
            formattedComponents.append(teeth.localizedLowercase + " teeth")
        }
        if let speech = speech?.ifNotEmpty() {
            formattedComponents.append(speech.localizedLowercase + " speech")
        }
        if let occupation = occupation?.ifNotEmpty() {
            formattedComponents.append(occupation.localizedLowercase)
        }
        if let maritalStatus = maritalStatus?.ifNotEmpty() {
            formattedComponents.append(maritalStatus.localizedLowercase)
        }
        if let religion = religion?.ifNotEmpty() {
            formattedComponents.append(religion.localizedLowercase)
        }
        
        if formattedComponents.isEmpty {
            return nil
        }
        return formattedComponents.joined(separator: ", ")
    }
    
}
