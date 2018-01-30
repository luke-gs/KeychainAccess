//
//  ResourceActivityLogViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceActivityLogViewController: ActivityLogViewController {

    open var activityLogViewModel: ResourceActivityLogViewModel? {
        return viewModel as? ResourceActivityLogViewModel
    }

    public init(viewModel: ResourceActivityLogViewModel) {
        super.init(viewModel: viewModel)
        
        sidebarItem.image = AssetManager.shared.image(forKey: .list)

//        if viewModel.allowCreate() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
//        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc private func plusButtonTapped(_ item: UIBarButtonItem) {
        if let viewController = activityLogViewModel?.createNewActivityLogViewController() {
            presentFormSheet(viewController, animated: true)
        }
    }

}
