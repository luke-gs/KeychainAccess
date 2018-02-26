//
//  TaskDetailsOverviewFormViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class TaskDetailsOverviewFormViewController: IntrinsicHeightFormBuilderViewController {
    public let viewModel: TaskDetailsOverviewViewModel
    
    public init(viewModel: TaskDetailsOverviewViewModel) {
        self.viewModel = viewModel
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func construct(builder: FormBuilder) {
        for section in viewModel.sections {
            builder += HeaderFormItem(text: section.title?.uppercased(),
                                      style: .collapsible)
            
            for item in section.items {
                builder += ValueFormItem(title: item.title, value: item.value, image: item.image)
                    .width(item.width)
                    .onSelection({ cell in
                        item.selectAction?(cell)
                    }).accessory(item.accessory)
            }
        }
    }
}

extension TaskDetailsOverviewFormViewController: CADFormCollectionViewModelDelegate {
    public func sectionsUpdated() {
        reloadForm()
    }
}
