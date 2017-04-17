//
//  PersonSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class PersonSearchRequest: SearchRequest {

    override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
    var searchType: SearchType = .name
    var states: [String]?
    var gender: [String]?
    var ageRange: Range<Int>?
    
    
    // MARK: - Initializers
    
    required init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
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
    
}
