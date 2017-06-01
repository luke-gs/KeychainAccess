//
//  VehicleSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

private let searchTypeKey  = "searchType"
private let statesKey      = "states"
private let makesKey       = "makes"
private let modelsKey      = "models"

@objc(MPLVehicleSearchRequest)
class VehicleSearchRequest: SearchRequest {
    
    enum SearchType: Int, Pickable {
        case vehicleRegistration
        
        var title: String? {
            switch self {
            case .vehicleRegistration: return NSLocalizedString("Vehicle Registration", comment: "")
            }
        }
        
        var subtitle: String? {
            return nil
        }
        
        static var all: [SearchType] = [.vehicleRegistration]
    }
    
    override class var localizedDisplayName: String {
        return NSLocalizedString("Vehicle", comment: "")
    }
    
    
    // MARK: - Properties
    
    var searchType: SearchType = .vehicleRegistration
    var states:  [ArchivedManifestEntry]?
    var makes:   [ArchivedManifestEntry]?
    var models:  [ArchivedManifestEntry]?
    
    
    // MARK: - Initializers
    
    required init(searchText: String? = nil) {
        super.init(searchText: searchText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        if aDecoder.containsValue(forKey: searchTypeKey),
            let type = SearchType(rawValue: aDecoder.decodeInteger(forKey: searchTypeKey)) {
            searchType = type
        }
        states  = aDecoder.decodeObject(of: NSArray.self, forKey: statesKey) as? [ArchivedManifestEntry]
        makes   = aDecoder.decodeObject(of: NSArray.self, forKey: makesKey)  as? [ArchivedManifestEntry]
        models  = aDecoder.decodeObject(of: NSArray.self, forKey: modelsKey) as? [ArchivedManifestEntry]
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(searchType.rawValue, forKey: searchTypeKey)
        aCoder.encode(states, forKey: statesKey)
        aCoder.encode(makes, forKey: makesKey)
        aCoder.encode(models, forKey: modelsKey)
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! VehicleSearchRequest
        copy.searchType = searchType
        copy.states = states
        copy.makes = makes
        copy.models = models
        return copy
    }
    
    
    // TODO: Equality checking
    
}
    
