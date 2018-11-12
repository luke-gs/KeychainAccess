//
//  ResourceAnnotation.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
open class ResourceAnnotation: TaskAnnotation {

    open var icon: UIImage?
    open var iconBackgroundColor: UIColor
    open var iconTintColor: UIColor?
    open var duress: Bool

    public init(identifier: String, source: CADTaskListSourceType, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, icon: UIImage?, iconBackgroundColor: UIColor, iconTintColor: UIColor?, duress: Bool) {
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.iconTintColor = iconTintColor
        self.duress = duress
        super.init(identifier: identifier, source: source, coordinate: coordinate, title: title, subtitle: subtitle)
    }

    open override func dequeueReusableAnnotationView(mapView: MKMapView) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ResourceAnnotationView.defaultReuseIdentifier) as? ResourceAnnotationView

        if annotationView == nil {
            annotationView = ResourceAnnotationView(annotation: self, reuseIdentifier: ResourceAnnotationView.defaultReuseIdentifier)
        }

        annotationView?.configure(withAnnotation: self,
                                  circleBackgroundColor: iconBackgroundColor,
                                  resourceImage: icon,
                                  imageTintColor: iconTintColor,
                                  duress: duress)

        return annotationView
    }
}
