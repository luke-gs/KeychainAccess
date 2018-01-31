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

    public init(report: Reportable?) {
        self.report = report as? DefaultDateAndTimeReport
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        sidebarItem.regularTitle = "Date and Time"
        sidebarItem.compactTitle = "Date and Time"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.date)!
    }

    override open func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "REPORTED ON")

        builder += DateFormItem()
            .title("Report Time")
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .onValueChanged { date in
                self.report?.reportedOnDateTime = date
            }
            .required()

        builder += HeaderFormItem(text: "TOOK PLACE FROM")

        builder += DateFormItem()
            .title("Start")
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .onValueChanged { date in
                self.report?.tookPlaceFromStartDateTime = date
            }
            .required()

        builder += DateFormItem()
            .title("End")
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .onValueChanged { date in
                self.report?.tookPlacefromEndDateTime = date
        }
    }
}

public class DefaultDateAndTimeReport: Reportable {

    var reportedOnDateTime: Date?
    var tookPlaceFromStartDateTime: Date?
    var tookPlacefromEndDateTime: Date?

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
