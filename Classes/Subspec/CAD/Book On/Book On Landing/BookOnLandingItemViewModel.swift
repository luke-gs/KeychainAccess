//
//  BookOnLandingItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model of not booked on screen items
open class BookOnLandingItemViewModel {
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
open class BookOnLandingCallsignItemViewModel: BookOnLandingItemViewModel {
    open let resource: SyncDetailsResource

    open var callsign: String
    open var status: CADResourceStatusType?
    open var location: String?
    open var caption: String?
    open var type: CADResourceUnitType?

    open var badgeText: String?
    open var badgeTextColor: UIColor?
    open var badgeBorderColor: UIColor?
    open var badgeFillColor: UIColor?
    
    /// Create a view model from the callsign resource
    public init(resource: SyncDetailsResource) {
        // Get icon colors
        let (imageColor, imageBackgroundColor) = resource.statusType.iconColors

        // Fetch current incident, for badge text and colors
        let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
        let (badgeTextColor, badgeBorderColor, badgeFillColor) = incident?.grade.badgeColors ?? (.clear, .clear, .clear)

        let title = [resource.callsign, resource.officerCountString].joined()
        let subtitle = resource.location?.suburb ?? resource.station ?? ThemeConstants.longDash
        let caption = [resource.statusType.rawValue, resource.currentIncident?.title].joined(separator: ThemeConstants.dividerSeparator)

        self.resource = resource
        self.callsign = resource.callsign
        self.status = resource.statusType
        self.location = resource.location?.fullAddress.ifNotEmpty()
        self.type = resource.type
        self.badgeText = incident?.grade.rawValue
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.caption = caption

        super.init(title: title, subtitle: subtitle, image: resource.type.icon, imageColor: imageColor, imageBackgroundColor: imageBackgroundColor)
    }
}
