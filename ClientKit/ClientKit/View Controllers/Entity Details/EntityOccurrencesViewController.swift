//
//  EntityOccurrencesViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class EntityOccurrencesViewController: FormCollectionViewController, EntityDetailSectionUpdatable {

    open var entity: MPOLKitEntity? {
        didSet {
            updateNoContentSubtitle()
            loadingManager.state = .noContent // Temp
        }
    }
    
    public override init() {
        super.init()
        title = NSLocalizedString("Events", comment: "")
        
        sidebarItem.image = AssetManager.shared.image(forKey: .list)
        
        let filterBarItem = FilterBarButtonItem(target: nil, action: nil)
        filterBarItem.isEnabled = false
        navigationItem.rightBarButtonItem = filterBarItem
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("EntityOccurrencesViewController does not support NSCoding.")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingManager.noContentView.titleLabel.text = NSLocalizedString("No Events Found", comment: "")
        updateNoContentSubtitle()
    }
    
    
    private func updateNoContentSubtitle() {
        let entityDisplayName: String
        if let entity = entity as? Entity {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        loadingManager.noContentView.subtitleLabel.text = String(format: NSLocalizedString("This %@ has no related events", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    

}
