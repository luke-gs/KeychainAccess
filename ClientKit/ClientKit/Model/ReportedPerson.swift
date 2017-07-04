//
//  ReportedPerson.swift
//
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox
import MPOLKit

@objc(MPLReportedPerson)
open class ReportedPerson: NSObject, Serialisable {
    
    open let id: String
    open var fullName: String?
    open var isCooperating: Bool?
    open var age: Int?
    open var fearLevel: String?
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "personId") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        fullName = unboxer.unbox(key: "fullName")
        isCooperating = unboxer.unbox(key: "cooperating")
        age = unboxer.unbox(key: "age")
        fearLevel = unboxer.unbox(key: "fearLevel")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(id)) as String? else {
            return nil
        }
        
        self.id = id
        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
}
