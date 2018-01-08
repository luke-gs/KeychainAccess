//
//  IncidentOverviewFormViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentOverviewFormViewController: IntrinsicHeightFormBuilderViewController {
    
    public let viewModel: IncidentOverviewViewModel
    
    public init(viewModel: IncidentOverviewViewModel) {
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
                builder += ValueFormItem(title: item.title, value: item.value, image: item.image)
                    .width(item.width)
                    .onSelection({ cell in
                        item.selectAction?(cell)
                    })
            }
        }
    }
}

