//
//  PersonSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

private let statesKey      = "states"
private let genderKey      = "gender"
private let searchTypeKey  = "searchType"
private let ageRangeMinKey = "ageRangeMin"
private let ageRangeMaxKey = "ageRangeMax"



@objc(MPLPersonSearchRequest)
class PersonSearchRequest: SearchRequest {
    
    enum SearchType: Int, Pickable {
        case name
        
        var title: String? {
            switch self {
            case .name: return NSLocalizedString("Name", comment: "")
            }
        }
        
        var subtitle: String? {
            return nil
        }
        
        static var all: [SearchType] = [.name]
    }
    

    override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
    var searchType: SearchType = .name
    var states: [ArchivedManifestEntry]?
    var gender: Person.Gender?
    var ageRange: Range<Int>?
    
    
    // MARK: - Initializers
    
    required init(searchText: String? = nil) {
        super.init(searchText: searchText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        searchType = SearchType(rawValue: aDecoder.decodeInteger(forKey: searchTypeKey)) ?? .name
        states     = aDecoder.decodeObject(of: NSArray.self, forKey: #keyPath(states)) as? [ArchivedManifestEntry]
        if aDecoder.containsValue(forKey: ageRangeMinKey), aDecoder.containsValue(forKey: ageRangeMaxKey) {
            ageRange = Range<Int>(uncheckedBounds: (aDecoder.decodeInteger(forKey: ageRangeMinKey), aDecoder.decodeInteger(forKey: ageRangeMaxKey)))
        }
        if aDecoder.containsValue(forKey: genderKey) {
            gender = Person.Gender(rawValue: aDecoder.decodeInteger(forKey: genderKey))
        }
        
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(searchType.rawValue, forKey: searchTypeKey)
        aCoder.encode(states, forKey: #keyPath(states))
        aCoder.encode(ageRange?.lowerBound, forKey: ageRangeMinKey)
        aCoder.encode(ageRange?.upperBound, forKey: ageRangeMaxKey)
        
        // TEMP
        if let gender = self.gender {
            aCoder.encode(gender.rawValue, forKey: genderKey)
        }
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PersonSearchRequest
        copy.searchType = searchType
        copy.states     = states
        copy.gender     = gender
        copy.ageRange   = ageRange
        return copy
    }
    
}
