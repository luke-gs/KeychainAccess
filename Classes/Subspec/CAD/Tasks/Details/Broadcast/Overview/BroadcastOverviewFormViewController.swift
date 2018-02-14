//
//  BroadcastOverviewFormViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class BroadcastOverviewFormViewController: IntrinsicHeightFormBuilderViewController {
    public let viewModel: BroadcastOverviewViewModel
    
    public init(viewModel: BroadcastOverviewViewModel) {
        self.viewModel = viewModel
        super.init()
        title = viewModel.navTitle()
        sidebarItem.image = AssetManager.shared.image(forKey: .info)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func construct(builder: FormBuilder) {
        for section in viewModel.sections {
            builder += HeaderFormItem(text: section.title.uppercased(),
                                      style: .collapsible)
            
            for item in section.items {
                builder += ValueFormItem(title: item.title, value: item.value, image: item.image).width(item.width)
            }
        }
    }
}

// MARK: - CADFormCollectionViewModelDelegate
extension BroadcastOverviewFormViewController: CADFormCollectionViewModelDelegate {
    
    public func sectionsUpdated() {
        // Reload content
        reloadForm()
    }
}
