//
//  DateViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit


class DateViewController: FormBuilderViewController {

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()

    override func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "DATE EXAMPLES")

        builder += DateFormItem()
            .title("Birthdate")
            .dateFormatter(.formDate)
            .width(.column(2))

        builder += DateFormItem()
            .title("VicPol Date")
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .formatter({ (date) -> String in
                let dateString = DateFormatter.shortDate.string(from: date)
                let timeString = DateFormatter.formTime.string(from: date)
                return "\(dateString), \(timeString)"
            })

        builder += DateFormItem()
            .title("Time")
            .dateFormatter(timeFormatter)
            .width(.column(2))
            .datePickerMode(.time)

        builder += DateFormItem()
            .title("24hr Time")
            .dateFormatter(.formTime)
            .width(.column(2))
            .datePickerMode(.time)
            .locale(Locale(identifier: "de"))

        builder += DateFormItem()
            .title("Holiday start date")
            .datePickerMode(.dateAndTime)
            .width(.column(1))
            .formatter({(date) -> String in
                let dateString = DateFormatter.formDateAndTime.string(from: date)
                return "You have selected \(dateString)"
            })

    }

}

