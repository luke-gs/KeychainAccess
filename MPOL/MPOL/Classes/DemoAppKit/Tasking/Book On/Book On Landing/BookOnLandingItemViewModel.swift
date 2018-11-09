//
//  BookOnLandingItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PatternKit
/// View model of not booked on screen items
open class BookOnLandingItemViewModel {
    open var title: String
    open var subtitle: String?
    open var imageColor: UIColor?
    open var imageBackgroundColor: UIColor?

    private var _originalImage: UIImage?
    private var _processedImage: UIImage?

    /// Lazy loading the image to avoid processing this for every row before it is displayed
    open var image: UIImage? {
        get {
            if _processedImage == nil {
                if imageBackgroundColor != nil {
                    _processedImage = _originalImage?.withCircleBackground(tintColor: imageColor,
                                                                           circleColor: imageBackgroundColor,
                                                                           style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                         padding: CGSize(width: 25, height: 25)),
                                                                           shouldCenterImage: true)
                } else {
                    _processedImage = _originalImage
                }
            }

            return _processedImage
        }
        set {
            _processedImage = image
        }
    }

    public init(title: String, subtitle: String?, image: UIImage?, imageColor: UIColor?, imageBackgroundColor: UIColor?) {
        self.title = title
        self.subtitle = subtitle
        self.imageColor = imageColor
        self.imageBackgroundColor = imageBackgroundColor
        self._originalImage = image
    }
}

/// View model of callsign section of not booked on screen
open class BookOnLandingCallsignItemViewModel: BookOnLandingItemViewModel {
    public let resource: CADResourceType

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
    public init(resource: CADResourceType) {
        // Get icon colors
        let (imageColor, imageBackgroundColor) = resource.status.iconColors

        // Fetch current incident, for badge text and colors
        let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
        let (badgeTextColor, badgeBorderColor, badgeFillColor) = incident?.grade.badgeColors ?? (.clear, .clear, .clear)

        let title = [resource.callsign, resource.officerCountString].joined()
        let subtitle = resource.location?.suburb ?? resource.station ?? ThemeConstants.longDash
        let caption = [resource.status.rawValue, resource.currentIncident?.title?.sizing().string].joined(separator: ThemeConstants.dividerSeparator)

        self.resource = resource
        self.callsign = resource.callsign
        self.status = resource.status
        self.location = resource.location?.fullAddress?.ifNotEmpty()
        self.type = resource.type
        self.badgeText = incident?.grade.rawValue
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.caption = caption

        super.init(title: title, subtitle: subtitle, image: resource.type.icon, imageColor: imageColor, imageBackgroundColor: imageBackgroundColor)
    }

    public init(resource: CADResourceType, callsign: String, title: String, subtitle: String?, image: UIImage?, imageColor: UIColor?, imageBackgroundColor: UIColor?) {
        self.resource = resource
        self.callsign = resource.callsign

        super.init(title: title, subtitle: subtitle, image: resource.type.icon, imageColor: imageColor, imageBackgroundColor: imageBackgroundColor)
    }

}
