//
//  BroadcastAnnotation.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 7/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class BroadcastAnnotation: TaskAnnotation {
    open var usesDarkBackground: Bool

    public init(identifier: String, source: CADTaskListSourceType, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, usesDarkBackground: Bool) {
        self.usesDarkBackground = usesDarkBackground
        super.init(identifier: identifier, source: source, coordinate: coordinate, title: title, subtitle: subtitle)
    }

    open override func dequeueReusableAnnotationView(mapView: MKMapView) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: BroadcastAnnotationView.defaultReuseIdentifier) as? BroadcastAnnotationView

        if annotationView == nil {
            annotationView = BroadcastAnnotationView(annotation: self, reuseIdentifier: BroadcastAnnotationView.defaultReuseIdentifier)
        }

        annotationView?.configure(withAnnotation: self, usesDarkBackground: usesDarkBackground)
        return annotationView
    }
}
