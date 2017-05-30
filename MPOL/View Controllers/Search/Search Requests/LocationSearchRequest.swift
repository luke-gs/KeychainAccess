//
//  LocationSearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

@objc(MPLLocationSearchRequest)
class LocationSearchRequest: SearchRequest  {
    
    override class var localizedDisplayName: String {
        return NSLocalizedString("Location", comment: "")
    }
    
    
    // MARK: - Initializers
    
    required init(searchText: String? = nil) {
        super.init(searchText: searchText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
}
