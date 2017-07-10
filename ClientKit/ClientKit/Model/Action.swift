//
//  Action.swift
//  Pods
//
//  Created by Herli Halim on 6/6/17.
//
//

import Unbox
import MPOLKit

@objc(MPLAction)
open class Action: NSObject, Serialisable {
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public enum ActionType: String, UnboxableEnum {
        case bail = "BAIL"
        case intOrderCompainant = "INT ORDER COMPLAINANT"
        case intOrderRespondent = "INT ORDER RESPONDENT"
        case missingPerson = "MISSING PERSON"
        case warrant = "WARRANT"
        case nameWhereabouts = "NAME WHEREABOUTS"
        case parole = "PAROLE"
        case cco = "CCO"
    }
    
    open let id : String
    open var type: ActionType?
    open var date: Date?
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        
        // Test data doesn't have id, temporarily removed this
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        type = unboxer.unbox(key: "actionType")
        date = unboxer.unbox(key: "date", formatter: Action.dateTransformer)
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
}

extension Action.ActionType: Pickable {
    
    public static let allCases: [Action.ActionType] = [.bail, .intOrderCompainant, .intOrderRespondent, .missingPerson, .warrant, .nameWhereabouts, .parole, .cco]
    
    public var title: String? {
        switch self {
        case .bail:               return NSLocalizedString("Bail", comment: "")
        case .intOrderCompainant: return NSLocalizedString("Int Order Complainant", comment: "")
        case .intOrderRespondent: return NSLocalizedString("Int Order Respondent", comment: "")
        case .missingPerson:      return NSLocalizedString("Missing Person", comment: "")
        case .warrant:            return NSLocalizedString("Warrant", comment: "")
        case .nameWhereabouts:    return NSLocalizedString("Name Whereabouts", comment: "")
        case .parole:             return NSLocalizedString("Parole", comment: "")
        case .cco:                return NSLocalizedString("CCO", comment: "")
        }
    }
    
    public var subtitle: String? {
        return nil
    }
    
}
