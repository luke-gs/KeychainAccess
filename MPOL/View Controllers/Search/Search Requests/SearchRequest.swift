//
//  SearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


class SearchRequest: NSObject, NSCoding {
    
    class var localizedDisplayName: String {
        return NSLocalizedString("Any Entity", comment: "")
    }
    
    var searchText: String?
    
    
    required override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        // TODO
    }
    
    func encode(with aCoder: NSCoder) {
        // TODO
    }
    
}


