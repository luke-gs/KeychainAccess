//
//  VehicleSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

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
    
    required init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        states  = aDecoder.decodeObject(of: NSArray.self, forKey: #keyPath(states)) as? [ArchivedManifestEntry]
        makes   = aDecoder.decodeObject(of: NSArray.self, forKey: #keyPath(makes)) as? [ArchivedManifestEntry]
        models  = aDecoder.decodeObject(of: NSArray.self, forKey: #keyPath(models)) as? [ArchivedManifestEntry]
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }

}
    
