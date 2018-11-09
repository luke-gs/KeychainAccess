//
//  ResourceActivityLogViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreKit

open class ResourceActivityLogViewController: ActivityLogViewController, TaskDetailsLoadable {

    public init(viewModel: ResourceActivityLogViewModel) {
        super.init(viewModel: viewModel)

        sidebarItem.image = AssetManager.shared.image(forKey: .list)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}
