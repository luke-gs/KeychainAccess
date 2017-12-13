//
//  ResourceActivityLogViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceActivityLogViewController: ActivityLogViewController {

    public override init(viewModel: CADFormCollectionViewModel<ActivityLogItemViewModel>) {
        super.init(viewModel: viewModel)
        
        sidebarItem.image = AssetManager.shared.image(forKey: .list)
        sidebarItem.count = UInt(viewModel.totalNumberOfItems())
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

}
