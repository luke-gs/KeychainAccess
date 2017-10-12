//
//  ListViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 20/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class ListViewController: FormViewController {

    override func construct(builder: FormBuilder) {

        builder.title = "List"

        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "ITEMS")
        builder += SubtitleFormItem(title: "Item 1", subtitle: "Item 1 subtitle", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 2", subtitle: "Item 2 subtitle", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 3", subtitle: "Item 3 subtitle", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 4", subtitle: "Item 4 subtitle", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 5", subtitle: "Item 5 subtitle", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 6", subtitle: "Item 6 subtitle", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "item 7", subtitle: "Item 7 subtitle", image: #imageLiteral(resourceName: "SidebarInfo"))

        builder += HeaderFormItem(text: "SPECIAL ITEMS")
        builder += ValueFormItem(title: "Special item 1", value: "$100", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Special item 2", value: "$200", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Special item 3", value: "$300", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Special item 4", value: "$400", image: #imageLiteral(resourceName: "SidebarInfo"))

    }

}
