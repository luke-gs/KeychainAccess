//
//  EntityOccurrencesViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class EntityOccurrencesViewController: EntityDetailCollectionViewController {

    open override var entity: Entity? {
        didSet {
            updateNoContentSubtitle()
            loadingManager.state = .noContent // Temp
        }
    }
    
    public override init() {
        super.init()
        title = NSLocalizedString("Involvements", comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconFormOccurrence",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormOccurrenceFilled", in: .mpolKit, compatibleWith: nil)
        
        let filterIcon = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: .mpolKit, compatibleWith: nil), style: .plain, target: nil, action: nil)
        filterIcon.isEnabled = false
        navigationItem.rightBarButtonItem = filterIcon
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("EntityOccurrencesViewController does not support NSCoding.")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingManager.noContentView.titleLabel.text = NSLocalizedString("No Involvements Found", comment: "")
        updateNoContentSubtitle()
    }
    
    
    private func updateNoContentSubtitle() {
        let entityDisplayName: String
        if let entity = entity {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        loadingManager.noContentView.subtitleLabel.text = String(format: NSLocalizedString("This %@ has no related involvements", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    

}
