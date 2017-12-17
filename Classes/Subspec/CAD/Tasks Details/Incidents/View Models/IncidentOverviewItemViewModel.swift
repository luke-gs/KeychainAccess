//
//  IncidentOverviewItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public struct IncidentOverviewItemViewModel {
    
    public typealias SelectAction = (CollectionViewFormCell) -> Void
    
    public var title: String?
    public var value: String?
    public var image: UIImage?
    public var width: BaseFormItem.HorizontalDistribution
    public var selectAction: SelectAction?
    
    public init(title: String?, value: String?, image: UIImage? = nil, width: BaseFormItem.HorizontalDistribution, selectAction: SelectAction? = nil) {
        self.title = title
        self.value = value
        self.image = image
        self.width = width
        self.selectAction = selectAction
    }
}
