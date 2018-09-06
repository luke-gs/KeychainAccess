//
//  BroadcastNarrativeViewController.swift
//  DemoAppKit
//
//  Created by Campbell Graham on 6/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class BroadcastNarrativeViewController: ActivityLogViewController, TaskDetailsLoadable {

    public init(viewModel: BroadcastNarrativeViewModel) {
        super.init(viewModel: viewModel)

        sidebarItem.image = AssetManager.shared.image(forKey: .list)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
