//
//  BasicViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit


class BasicViewController: FormViewController {

    override func construct(builder: FormBuilder) {

        builder.title = "Basic"

        /// Creating basic section
        builder.add(HeaderFormItem(text: "DETAILS"))
        builder.add(SubtitleFormItem(title: "Name", subtitle: "Herli Halim", image: #imageLiteral(resourceName: "SidebarInfo")))
        builder.add(ValueFormItem(title: "Age", value: "27", image: #imageLiteral(resourceName: "SidebarInfo")))
        builder.add(DetailFormItem(title: "Property", subtitle: "44 Heartlands Blv", detail: "Current PPOR", image: #imageLiteral(resourceName: "SidebarInfo")))

        /// Adding multiple items
        builder.add([
            HeaderFormItem(text: "GIRLFRIENDS"),
            SubtitleFormItem(title: "Name", subtitle: "Bryan Hathaway", image: #imageLiteral(resourceName: "SidebarInfo")),
            SubtitleFormItem(title: "Name", subtitle: "Pavel Boryseiko", image: #imageLiteral(resourceName: "SidebarInfo")),
            SubtitleFormItem(title: "Name", subtitle: "Luke Sammut", image: #imageLiteral(resourceName: "SidebarInfo"))
        ])

        /// Short hand
        builder += HeaderFormItem(text: "BOYFRIENDS")
        builder += SubtitleFormItem(title: "Name", subtitle: "Bryan Hathaway", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Name", subtitle: "Pavel Boryseiko", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Name", subtitle: "Luke Sammut", image: #imageLiteral(resourceName: "SidebarInfo"))

        builder += [
            HeaderFormItem(text: "SLAVES"),
            SubtitleFormItem(title: "Name", subtitle: "Bryan Hathaway", image: #imageLiteral(resourceName: "SidebarInfo")),
            SubtitleFormItem(title: "Name", subtitle: "Pavel Boryseiko", image: #imageLiteral(resourceName: "SidebarInfo")),
            SubtitleFormItem(title: "Name", subtitle: "Luke Sammut", image: #imageLiteral(resourceName: "SidebarInfo"))
        ]

        builder += HeaderFormItem(text: "BOSSES")
        builder += SubtitleFormItem(title: "Mariana", subtitle: "Big Boss").width(.column(1))
        builder += SubtitleFormItem(title: "James Aramroongrot", subtitle: "Mini Boss").width(.column(1))

    }

}
