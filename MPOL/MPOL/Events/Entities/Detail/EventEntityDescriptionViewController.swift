//
//  EventEntityDescriptionViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class EventEntityDescriptionViewController: FormBuilderViewController {

    var viewModel: EventEntityDescriptionViewModel

    public required init(viewModel: EventEntityDescriptionViewModel) {
        self.viewModel = viewModel
        super.init()

        self.title = "Description"

        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.info)!
        sidebarItem.color = .red
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func construct(builder: FormBuilder) {

        let displayable = viewModel.displayable()
        
        builder += SummaryDetailFormItem()
            .category(displayable.category)
            .title(displayable.title)
            .detail(viewModel.description())
            .subtitle(displayable.detail1)
            .borderColor(displayable.borderColor)
            .image(displayable.thumbnail(ofSize: .large))
    }
}

