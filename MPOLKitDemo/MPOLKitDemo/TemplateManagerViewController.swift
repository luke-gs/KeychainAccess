//
//  TemplateManagerViewController.swift
//  MPOLKitDemo
//
//  Created by Kara Valentine on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class TemplateManagerViewController: FormBuilderViewController {

    // todo
    // - plus button to add template
    // - add template dialog
    // - template manager interactions
    // - select template form item
    // - select template dialog with local and network sections

    override func construct(builder: FormBuilder) {
        builder.title = "Templates"

        builder += HeaderFormItem(text: "TEMPLATE DEMO")

        builder += SubtitleFormItem(title: "Select Template", subtitle: "Tap this to select a template", image: nil)
    }
}
