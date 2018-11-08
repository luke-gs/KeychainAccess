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
                    .separatorColor(.clear)
            }
            builder += section.items
        }
    }
}

extension TaskDetailsOverviewFormViewController: CADFormCollectionViewModelDelegate {
    public func sectionsUpdated() {
        reloadForm()
    }
}
