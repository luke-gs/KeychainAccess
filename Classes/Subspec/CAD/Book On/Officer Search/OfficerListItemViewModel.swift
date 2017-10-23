//
//  OfficerListItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct OfficerListItemViewModel: GenericSearchable {
    
    public var title: String
    public var subtitle: String?
    public var section: String?
    public var image: UIImage?
    
    public func contains(searchString: String) -> Bool {
        return title.localizedCaseInsensitiveContains(searchString)
    }
    
}
