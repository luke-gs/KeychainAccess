//
//  PersonDescription.swift
//  Pods
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
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        
        super.init()
    }
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: "id") as String? else {
            return nil
        }
        self.id = id
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
    }
    
    public func formatted() -> String? {
        var initialString = ""
        if let height = height {
            initialString = "\(height) cm "
        }
        if let build = build, build.isEmpty == false {
            initialString += build.lowercased(with: nil)
            initialString += " "
        }
        if let weight = weight, weight.isEmpty == false {
            initialString += "\(weight)"
        }
        if let complexion = complexion, complexion.isEmpty == false {
            initialString += complexion.lowercased(with: nil)
            initialString += " "
        }
        if let indigenousStatus = indigenousAustralianStatus, indigenousStatus.isEmpty == false {
            initialString += indigenousStatus.lowercased()
            initialString += " "
        } else if let nationality = nationality, nationality.isEmpty == false {
            initialString += nationality.lowercased(with: nil)
            initialString += " "
        }
        
        initialString = initialString.trimmingCharacters(in: .whitespaces)
        
        var formattedComponents: [String] = []
        
        if initialString.isEmpty == false {
            formattedComponents.append(initialString)
        }
        
        var hair = ""
        if let hairLength = hairLength, hairLength.isEmpty == false {
            hair += hairLength.lowercased(with: nil)
            hair += " "
        }
        if let hairColour = hairColour, hairColour.isEmpty {
            hair += hairColour.lowercased(with: nil)
            hair += " "
        }
        if hair.isEmpty == false {
            hair += "hair"
            formattedComponents.append(hair)
        }
        if let eyeColour = eyeColour, eyeColour.isEmpty == false {
            formattedComponents.append(eyeColour.lowercased(with: nil) + " eyes")
        }
        if let glasses = glasses, glasses.isEmpty == false {
            formattedComponents.append(glasses.lowercased(with: nil) + " glasses")
        }
        if let facialHair = facialHair, facialHair.isEmpty == false {
            formattedComponents.append(facialHair.lowercased(with: nil) + " facial hair")
        }
        if let teeth = teeth, teeth.isEmpty == false {
            formattedComponents.append(teeth.lowercased(with: nil) + " teeth")
        }
        if let speech = speech, speech.isEmpty == false {
            formattedComponents.append(speech.lowercased(with: nil) + " speech")
        }
        if let occupation = occupation, occupation.isEmpty == false {
            formattedComponents.append(occupation.lowercased(with: nil))
        }
        if let maritalStatus = maritalStatus, maritalStatus.isEmpty == false {
            formattedComponents.append(maritalStatus.lowercased(with: nil))
        }
        if let religion = religion, religion.isEmpty == false {
            formattedComponents.append(religion.lowercased(with: nil))
        }
        
        if formattedComponents.isEmpty {
            return nil
        }
        return formattedComponents.joined(separator: ", ")
    }
    
}
