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
            hasContent = false // temp
        }
    }
    
    public override init() {
        super.init()
        title = NSLocalizedString("Involvements", comment: "")
        
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
        
        noContentTitleLabel?.text = NSLocalizedString("No Involvements Found", comment: "")
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
        
        label.text = String(format: NSLocalizedString("This %@ has no related involvements", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    

}
