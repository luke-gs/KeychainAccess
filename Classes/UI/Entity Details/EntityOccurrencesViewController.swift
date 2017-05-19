//
//  EntityOccurrencesViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityOccurrencesViewController: EntityDetailCollectionViewController {

    open override var entity: Entity? {
        didSet {
            updateNoContentSubtitle()
            hasContent = false // temp
        }
    }
    
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
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Occurrences Found", comment: "")
        updateNoContentSubtitle()
    }
    
    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        var noContentSubtitle = NSLocalizedString("This entity has no related occurrences", comment: "")
        if let entity = entity {
            noContentSubtitle = noContentSubtitle.replacingOccurrences(of: "entity", with: type(of: entity).localizedDisplayName.lowercased(with: nil))
        }
        label.text = noContentSubtitle
    }
    

}
