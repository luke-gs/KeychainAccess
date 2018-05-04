//
//  HeaderViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class HeaderViewController: FormBuilderViewController {

    override func construct(builder: FormBuilder) {

        builder.title = "Header Styles"

        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "EXPANDABLE", style: .collapsible)
        builder += SubtitleFormItem(title: "Item 1", subtitle: "Tap header to collapse", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 2", subtitle: "And tap again to expand", image: #imageLiteral(resourceName: "SidebarInfo"))

        builder += HeaderFormItem(text: "NON EXPANDABLE")
        builder += ValueFormItem(title: "Special item 1", value: "$100", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Special item 2", value: "$200", image: #imageLiteral(resourceName: "SidebarInfo"))

        builder += HeaderFormItem(text: "EXPANDABLE", style: .collapsible)
        builder += SubtitleFormItem(title: "Item 1", subtitle: "Tap header to collapse", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 2", subtitle: "And tap again to expand", image: #imageLiteral(resourceName: "SidebarInfo"))

        builder += HeaderFormItem()
        builder += SubtitleFormItem(title: "Item 1", subtitle: "Headerless", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 2", subtitle: "Plain header", image: #imageLiteral(resourceName: "SidebarInfo"))

        builder += HeaderFormItem()
        builder += SubtitleFormItem(title: "Item 1", subtitle: "Headerless", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 2", subtitle: "Plain header", image: #imageLiteral(resourceName: "SidebarInfo"))
        
        builder += LargeTextHeaderFormItem(text: "LARGE TEXT HEADER")
        builder += SubtitleFormItem(title: "Item 1", subtitle: "Headerless", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 2", subtitle: "Plain header", image: #imageLiteral(resourceName: "SidebarInfo"))
        
        builder += LargeTextHeaderFormItem(text: "LARGE TEXT HEADER WITH INSETS").layoutMargins(UIEdgeInsets(top: 32, left: 48, bottom: 48, right: 48))
        builder += SubtitleFormItem(title: "Item 1", subtitle: "Headerless", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Item 2", subtitle: "Plain header", image: #imageLiteral(resourceName: "SidebarInfo"))

    }

}
