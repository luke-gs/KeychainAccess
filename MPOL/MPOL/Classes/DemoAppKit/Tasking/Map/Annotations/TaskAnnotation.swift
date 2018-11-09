//
//  TaskAnnotation.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import CoreKit
open class TaskAnnotation: NSObject, MKAnnotation {

    open var coordinate: CLLocationCoordinate2D
    open var title: String?
    open var subtitle: String?
    open var identifier: String
    open var source: CADTaskListSourceType

    public init(identifier: String, source: CADTaskListSourceType, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.identifier = identifier
        self.source = source
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }

    override open func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TaskAnnotation else { return false }
        return identifier == object.identifier &&
            coordinate == object.coordinate &&
            title == object.title &&
            subtitle == object.subtitle
    }

    /// Dequeue or create an appropriate annotation view for this annotation
    open func dequeueReusableAnnotationView(mapView: MKMapView) -> MKAnnotationView? {
        MPLRequiresConcreteImplementation()
    }

    /// Create the task item details view model from this list item
    open func createItemViewModel() -> TaskItemViewModel? {
        return source.createItemViewModel(identifier: identifier)
    }

}
