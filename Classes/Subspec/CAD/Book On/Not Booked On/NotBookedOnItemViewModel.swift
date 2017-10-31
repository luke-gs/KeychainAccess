//
//  NotBookedOnItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model of not booked on screen items
open class NotBookedOnItemViewModel {
    open var title: String
    open var subtitle: String
    open var image: UIImage?
    open var imageColor: UIColor?
    open var imageBackgroundColor: UIColor?


    public init(title: String, subtitle: String, image: UIImage?, imageColor: UIColor?, imageBackgroundColor: UIColor?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.imageColor = imageColor
        self.imageBackgroundColor = imageBackgroundColor
    }
}

/// View model of callsign section of not booked on screen
open class NotBookedOnCallsignItemViewModel: NotBookedOnItemViewModel, BookOnCallsignViewModelType {
    public var callsign: String
    public var status: String?
    public var location: String?

    public init(callsign: String, status: String?, location: String?, image: UIImage?, imageColor: UIColor?) {
        self.callsign = callsign
        self.status = status
        self.location = location

        let subtitle = [location, status].removeNils().joined(separator: " : ")
        super.init(title: callsign, subtitle: subtitle, image: image, imageColor: imageColor, imageBackgroundColor: imageBackgroundColor)
    }
}
