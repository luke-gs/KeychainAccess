//
//  AccessoryViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class AccessoryViewController: FormViewController {

    override func construct(builder: FormBuilder) {

        builder.title = "Accessories"

        builder += HeaderFormItem(text: "ACCESSORIES")

        builder += SubtitleFormItem(title: "Disclosure", subtitle: "Disclosure", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(FormItemAccessory.disclosure)
            .width(.column(1))

        builder += SubtitleFormItem(title: "Checkmark", subtitle: "Checkmark", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(FormItemAccessory.checkmark)
            .width(.column(1))

        builder += SubtitleFormItem(title: "Dropdown", subtitle: "Dropdown", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(FormItemAccessory.dropDown)
            .width(.column(1))

    }

}
