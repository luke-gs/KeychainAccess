//
//  TaskAnnotation.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class TaskAnnotation: NSObject, MKAnnotation {
    
    open var coordinate: CLLocationCoordinate2D
    open var title: String?
    open var subtitle: String?
    open var status: String?
    open var identifier: String

    public init(identifier: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, status: String?) {
        self.identifier = identifier
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.status = status
    }
}
