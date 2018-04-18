//
//  EventEntityRelationshipsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class EventEntityRelationshipsViewController: FormBuilderViewController {

    public override init() {
        super.init()

        self.title = "Relationships"

        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconRelationships)!
        sidebarItem.color = .red
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func construct(builder: FormBuilder) {
        
    }
}
