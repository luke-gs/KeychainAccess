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
    
}
