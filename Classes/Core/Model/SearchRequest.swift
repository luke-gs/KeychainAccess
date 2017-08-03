//
//  SearchRequest.swift
//  MPOL
//
//  Created by Rod Brown on 12/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

@objc(MPLSearchRequest)
open class SearchRequest: NSObject {
    open func searchOperation(forSource source: EntitySource,
                              params: Parameterisable,
                              completion: ((_ entities: [MPOLKitEntity]?, _ error: Error?)->())?) throws
        -> (searchOperation: GroupOperation, updateDataOperation: BlockOperation)?
    {
        MPLRequiresConcreteImplementation()
    }
}


