//
//  PersonDetailViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 14/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class PersonDetailViewController: FormViewController {

    override func construct(builder: FormBuilder) {

        builder.title = "Person Details"

        builder += HeaderFormItem(text: "DETAILS")

        builder += SubtitleFormItem(title: "Name", subtitle: StringSizing(string: "Herli Halim", font: .boldSystemFont(ofSize: 20)), image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Spouse", subtitle: "Marianna", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Age", value: "2", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Sex", value: "Confused", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += DetailFormItem(title: "Property", subtitle: "44 Heartlands Blv", detail: "Current PPOR", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += DetailFormItem(title: "Property", subtitle: "108 Flinders St", detail: "Previous PPOR")

        builder += [
            HeaderFormItem(text: "ALIAS"),
            SubtitleFormItem(title: "AKA", subtitle: "Black Herli").width(.column(2)),
            SubtitleFormItem(title: "Game Name", subtitle: "XSlasherzX").width(.column(2)),
            SubtitleFormItem(title: "Everyday's name", subtitle: "NoobieHalim").width(.column(2))
        ]

        var mangaItems: [FormItem] = [HeaderFormItem(text: "MANGA")]

        for i in 1...100 {
            let item = SubtitleFormItem(title: "Manager \(i)", subtitle: "Subtitle \(i)")
            item.accessory = ItemAccessory.disclosure
            item.width = .column(3)
            mangaItems.append(item)
        }

        builder += mangaItems
    }

}
