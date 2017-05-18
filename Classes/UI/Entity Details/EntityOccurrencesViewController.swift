//
//  EntityOccurrencesViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityOccurrencesViewController: FormCollectionViewController, EntityDetailViewController {
    
    open var entity: Entity?

    public override init() {
        super.init()
        title = "Occurrences"
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconFormOccurrence",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormOccurrenceFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
