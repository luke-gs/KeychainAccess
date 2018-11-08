//
//  TaskDetailsOverviewItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PatternKit
public struct TaskDetailsOverviewItemViewModel {

    public typealias SelectAction = (CollectionViewFormCell) -> Void

    public var title: String?
    public var value: String?
    public var image: UIImage?
    public var width: BaseFormItem.HorizontalDistribution
    public var selectAction: SelectAction?
    public var accessory: ItemAccessorisable?
    public var isAddress: Bool

    public init(title: String?, value: String?, image: UIImage? = nil, width: BaseFormItem.HorizontalDistribution, selectAction: SelectAction? = nil, accessory: ItemAccessorisable? = nil, isAddress: Bool = false) {
        self.title = title
        self.value = value
        self.image = image
        self.width = width
        self.selectAction = selectAction
        self.accessory = accessory
        self.isAddress = isAddress
    }

}
