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
    open var subtitle: String?
    open var image: UIImage?
    open var imageColor: UIColor?
    open var imageBackgroundColor: UIColor?

    public init(title: String, subtitle: String?, image: UIImage?, imageColor: UIColor?, imageBackgroundColor: UIColor?) {
        self.title = title
        self.subtitle = subtitle
        self.imageColor = imageColor
        self.imageBackgroundColor = imageBackgroundColor
        
        if imageBackgroundColor != nil {
            self.image = image?.withCircleBackground(tintColor: imageColor,
                                                     circleColor: imageBackgroundColor,
                                                     style: .fixed(size: CGSize(width: 48, height: 48),
                                                                   padding: CGSize(width: 25, height: 25)),
                                                     shouldCenterImage: true)
        } else {
            self.image = image
        }
    }
}

/// View model of callsign section of not booked on screen
open class NotBookedOnCallsignItemViewModel: NotBookedOnItemViewModel, BookOnCallsignViewModelType {
    public var callsign: String
    public var status: String?
    public var location: String?
    public var caption: String?
    public var type: ResourceType?

    open var badgeText: String?
    open var badgeTextColor: UIColor?
    open var badgeBorderColor: UIColor?
    open var badgeFillColor: UIColor?
    
    public init(title: String, subtitle: String?, caption: String?, callsign: String, status: String?, location: String?, type: ResourceType?, image: UIImage?, imageColor: UIColor?, imageBackgroundColor: UIColor?, badgeText: String? = nil, badgeTextColor: UIColor? = .clear, badgeFillColor: UIColor? = .clear, badgeBorderColor: UIColor? = .clear) {
        self.callsign = callsign
        self.status = status
        self.location = location
        self.type = type
        self.badgeText = badgeText
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.caption = caption

        super.init(title: title, subtitle: subtitle, image: image, imageColor: imageColor, imageBackgroundColor: imageBackgroundColor)
    }

    /// Create a view model from the callsign resource
    public convenience init(resource: SyncDetailsResource) {
        // Get icon colors
        let (imageColor, imageBackgroundColor) = resource.status.iconColors

        // Fetch current incident, for badge text and colors
        let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
        let (badgeTextColor, badgeBorderColor, badgeFillColor) = incident?.grade.badgeColors ?? (.clear, .clear, .clear)

        let title = [resource.callsign, resource.officerCountString].joined()
        let subtitle = resource.location?.suburb ?? resource.station ?? ThemeConstants.longDash
        let caption = [resource.status.rawValue, resource.currentIncident?.title].joined(separator: ThemeConstants.dividerSeparator)
        
        self.init(
            title: title,
            subtitle: subtitle,
            caption: caption,
            callsign: resource.callsign,
            status: resource.status.rawValue,
            location: resource.location?.fullAddress.ifNotEmpty(),
            type: resource.type,
            image: resource.type.icon,
            imageColor: imageColor,
            imageBackgroundColor: imageBackgroundColor,
            badgeText: incident?.grade.rawValue,
            badgeTextColor: badgeTextColor,
            badgeFillColor: badgeFillColor,
            badgeBorderColor: badgeBorderColor)
    }
}
