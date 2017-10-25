//
//  StepperViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 24/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class StepperViewController: FormBuilderViewController {

    override func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "STEPPER")

        builder += StepperFormItem(title: "Score")
            .minimumValue(1)
            .maximumValue(100)
            .width(.column(2))

        builder += StepperFormItem(title: "Score")
            .minimumValue(1)
            .maximumValue(100)
            .stepValue(5)
            .value(50)
            .width(.column(2))

        builder += StepperFormItem(title: "Decimal stepper")
            .minimumValue(1)
            .maximumValue(100)
            .stepValue(0.5)
            .numberOfDecimalPlaces(1)
            .width(.column(2))

        builder += StepperFormItem(title: "Decimal stepper")
            .minimumValue(1)
            .maximumValue(100)
            .stepValue(2.5)
            .value(50)
            .numberOfDecimalPlaces(2)
            .width(.column(2))

    }

}
