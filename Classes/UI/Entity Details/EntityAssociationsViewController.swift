//
//  EntityAssociationsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityAssociationsViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        didSet {
            updateNoContentSubtitle()
            hasContent = false // temp
        }
    }
    
    
    public override init() {
        super.init()
        title = "Associations"
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralAssociation",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralAssociationFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Associations Found", comment: "")
        updateNoContentSubtitle()
    }

    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        let entityDisplayName: String
        if let entity = entity {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        label.text = String(format: NSLocalizedString("This %@ has no associations", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    
}
