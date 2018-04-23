//
//  EventEntityRelationshipsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class EventEntityRelationshipsViewController: FormBuilderViewController {

    var viewModel: EventEntityRelationshipsViewModel

    required convenience init?(coder aDecoder: NSCoder) { MPLCodingNotSupported()}
    public init(viewModel: EventEntityRelationshipsViewModel) {
        self.viewModel = viewModel
        super.init()

        self.title = "Relationships"

        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconRelationships)!
        sidebarItem.color = viewModel.tintColour()
    }

    override func construct(builder: FormBuilder) {
        
    }
}
