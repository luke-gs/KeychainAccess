//
//  ProgressViewController.swift
//  MPOLKitDemo
//
//  Created by Megan Efron on 8/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class ProgressViewController: FormBuilderViewController {
    
    override func construct(builder: FormBuilder) {
        
        builder.title = "Progress"
        builder.forceLinearLayout = true
        
        builder += ProgressFormItem(title: "Valid until", value: "16/01/2018", detail: "100 days left")
            .progress(0.25)
            .progressTintColor(#colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1))
        
        builder += ProgressFormItem(title: "Valid until", value: "16/01/2017", detail: "Expired 150 days ago")
            .progress(0.5)
            .progressTintColor(#colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1))
        
        builder += ProgressFormItem(title: "Hidden progress", value: "I am hiding my progress view", detail: "No progress")
            .progress(1.0)
            .progressTintColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
            .isProgressHidden(true)
        
        builder += ProgressFormItem(title: "Without detail", value: "I am hiding my detail label")
            .progress(0.75)
            .progressTintColor(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
    }

}
