//
//  PersonSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

class PersonSearchRequest: SearchRequest {

    override class var localizedDisplayName: String {
        return NSLocalizedString("Person", comment: "")
    }
    
    
    private var searchTypeValue: String? = nil
    private var states: [String]? = nil
    private var gender: [String]? = nil
    private var ageRange: Range = Range(uncheckedBounds: (0, 100))
    
    
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
    
}
