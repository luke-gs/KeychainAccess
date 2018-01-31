//
//  EventDateTimeViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class DefaultEventDateTimeViewController: FormBuilderViewController {

    weak var report: DefaultDateAndTimeReport?

    public init(report: Reportable) {
        self.report = report as? DefaultDateAndTimeReport
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        sidebarItem.alertColor = .green
        sidebarItem.count = UInt(10)
        sidebarItem.regularTitle = "Date and Time"
        sidebarItem.compactTitle = "Date and Time"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.date)!
        sidebarItem.color = .red
    }

    override open func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "REPORTED ON")

        builder += DateFormItem()
            .title("Report Date")
            .dateFormatter(.longDate)
            .width(.column(2))
            .required()

        builder += DateFormItem()
            .title("Report Time")
            .datePickerMode(.time)
            .width(.column(2))
            .formatter({ (date) -> String in
                let formTime = DateFormatter.formTime.string(from: date)
                return formTime
            })
            .required()

        builder += HeaderFormItem(text: "TOOK PLACE FROM")

        builder += DateFormItem()
            .title("Start Date")
            .dateFormatter(.longDate)
            .width(.column(2))
            .required()

        builder += DateFormItem()
            .title("Start Time")
            .datePickerMode(.time)
            .width(.column(2))
            .formatter({ (date) -> String in
                let formTime = DateFormatter.formTime.string(from: date)
                return formTime
            })
            .required()

        builder += DateFormItem()
            .title("End Date")
            .dateFormatter(.longDate)
            .width(.column(2))
            .required()

        builder += DateFormItem()
            .title("End Time")
            .datePickerMode(.time)
            .width(.column(2))
            .formatter({ (date) -> String in
                let formTime = DateFormatter.formTime.string(from: date)
                return formTime
            })
            .required()
    }
}

public class DefaultDateAndTimeReport: Reportable {

    var reportedOn: Date?
    var tookPlaceFromStart: Date?
    var tookPlacefromEnd: Date?

    public weak var event: Event?

    public required init(event: Event) {
        self.event = event
    }

    public func encode(with aCoder: NSCoder) {
        //encode all
    }

    public required init?(coder aDecoder: NSCoder) {
        //decode all
    }

}
