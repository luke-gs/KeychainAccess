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
                    
                    var linkAttributes = [NSAttributedStringKey: Any]()
                    
                    if let tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint) {
                        linkAttributes[.foregroundColor] = tintColor
                    }
                    
                    builder += ValueFormItem(title: item.title,
                                             value: NSAttributedString(string: item.value ?? "",
                                                                       attributes: linkAttributes))
                        .width(.column(1))
                        .onSelection { cell in
                            item.selectAction?(cell)
                        }
                    
                } else {
                    builder += ValueFormItem(title: item.title,
                                             value: StringSizing(string: item.value ?? "Unknown"),
                                             image: item.image)
                        .width(item.width)
                        .accessory(item.accessory)
                        .onSelection{ cell in
                            item.selectAction?(cell)
                        }
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
