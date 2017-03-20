//
//  EntityAssociationsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class EntityAssociationsViewController: FormCollectionViewController {

    override init() {
        super.init()
        title = "Associations"
        
        let sidebarItem = self.sidebarItem
        let bundle = Bundle(for: FormCollectionViewController.self)
        sidebarItem.image         = UIImage(named: "iconGeneralAssociation",       in: bundle, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralAssociationFilled", in: bundle, compatibleWith: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
