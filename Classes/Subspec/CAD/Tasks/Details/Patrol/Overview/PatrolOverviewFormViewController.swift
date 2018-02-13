//
//  PatrolOverviewFormViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class PatrolOverviewFormViewController: IntrinsicHeightFormBuilderViewController {
    public let viewModel: PatrolOverviewViewModel
    
    public init(viewModel: PatrolOverviewViewModel) {
        self.viewModel = viewModel
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
