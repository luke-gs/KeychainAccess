//
//  AccessoryViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 3/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class AccessoryViewController: FormBuilderViewController {

    override func construct(builder: FormBuilder) {

        builder.title = "Accessories"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "ACCESSORIES")

        builder += SubtitleFormItem(title: "ItemAccessory", subtitle: "Disclosure", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(ItemAccessory.disclosure)

        builder += SubtitleFormItem(title: "ItemAccessory", subtitle: "Checkmark", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(ItemAccessory.checkmark)

        builder += SubtitleFormItem(title: "ItemAccessory", subtitle: "Dropdown", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(ItemAccessory.dropDown)

        builder += SubtitleFormItem(title: "LabeledItemAccessory", subtitle: "DropDown", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(LabeledItemAccessory(title: "Title", subtitle: "Subtitle", accessory: ItemAccessory.dropDown))

        builder += SubtitleFormItem(title: "CustomItemAccessory", subtitle: "ImageView", image: #imageLiteral(resourceName: "SidebarInfo"))
            .accessory(CustomItemAccessory(onCreate: { () -> UIView in
                return UIImageView(image: AssetManager.shared.image(forKey: .info))
            }, size: CGSize(width: 24.0, height: 24.0)))

    }

}
