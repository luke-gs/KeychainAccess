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
            if let title = section.title {
                builder += LargeTextHeaderFormItem(text: StringSizing(string: title))
            }
            for item in section.items {
                if item.isAddress {
                    builder += DetailLinkFormItem()
                        .title(StringSizing(string: item.title ?? "Unknown"))
                        .subtitle(item.value)
                        .width(.column(1))
                        .onSelection{ cell in
                            item.selectAction?(cell)
                    }
                } else {
                    builder += ValueFormItem(title: item.title,
                                             value: StringSizing(string: item.value ?? "Unknown"),
                                             image: item.image)
                        .width(item.width)
                        .onSelection({ cell in
                            item.selectAction?(cell)
                        }).accessory(item.accessory)
                }
            }
        }
    }
}

extension TaskDetailsOverviewFormViewController: CADFormCollectionViewModelDelegate {
    public func sectionsUpdated() {
        reloadForm()
    }
}
