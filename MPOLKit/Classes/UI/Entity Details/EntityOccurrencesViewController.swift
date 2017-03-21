//
//  EntityOccurrencesViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityOccurrencesViewController: FormCollectionViewController {

    public override init() {
        super.init()
        title = "Occurrences"
        
        let sidebarItem = self.sidebarItem
        let bundle = Bundle(for: FormCollectionViewController.self)
        sidebarItem.image         = UIImage(named: "iconFormOccurrence",       in: bundle, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormOccurrenceFilled", in: bundle, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
