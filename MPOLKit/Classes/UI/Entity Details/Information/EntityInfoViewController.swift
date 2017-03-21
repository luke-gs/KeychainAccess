//
//  EntityInfoViewController.swift
//  Pods
//
//  Created by Rod Brown on 21/3/17.
//
//

import UIKit

class EntityInfoViewController: FormCollectionViewController {
    
    override init() {
        super.init()
        title = "Information"
        
        let sidebarItem = self.sidebarItem
        let bundle = Bundle(for: FormCollectionViewController.self)
        sidebarItem.image         = UIImage(named: "iconGeneralInfo",       in: bundle, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralInfoFilled", in: bundle, compatibleWith: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
