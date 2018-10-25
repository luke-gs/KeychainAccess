//
//  IncidentAnnotation.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

open class IncidentAnnotation: TaskAnnotation {

    open var priority: CADIncidentGradeType
    open var badgeText: String
    open var badgeTextColor: UIColor
    open var badgeFillColor: UIColor
    open var badgeBorderColor: UIColor
    open var usesDarkBackground: Bool

    public init(identifier: String, source: CADTaskListSourceType, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, badgeText: String, badgeTextColor: UIColor, badgeFillColor: UIColor, badgeBorderColor: UIColor, usesDarkBackground: Bool, priority: CADIncidentGradeType) {
        self.badgeText = badgeText
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.usesDarkBackground = usesDarkBackground
        self.priority = priority
        super.init(identifier: identifier, source: source, coordinate: coordinate, title: title, subtitle: subtitle)
    }

    open override func dequeueReusableAnnotationView(mapView: MKMapView) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: IncidentAnnotationView.defaultReuseIdentifier) as? IncidentAnnotationView

        if annotationView == nil {
            annotationView = IncidentAnnotationView(annotation: self, reuseIdentifier: IncidentAnnotationView.defaultReuseIdentifier)
        }

        annotationView?.configure(withAnnotation: self,
                                  priorityText: badgeText,
                                  priorityTextColor: badgeTextColor,
                                  priorityFillColor: badgeFillColor,
                                  priorityBorderColor: badgeBorderColor,
                                  usesDarkBackground: usesDarkBackground)

        return annotationView
    }
}
