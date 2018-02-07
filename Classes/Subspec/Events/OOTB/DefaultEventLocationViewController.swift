//
//  DefaultEventLocationViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

import UIKit
import MapKit

fileprivate extension EvaluatorKey {
    static let eventLocation = EvaluatorKey(rawValue: "eventLocation")
}

open class DefaultEventLocationViewController: FormBuilderViewController, EvaluationObserverable {
    
    weak var report: DefaultLocationReport?
    
    public init(report: Reportable?) {
        self.report = report as? DefaultLocationReport
        super.init()
        report?.evaluator.addObserver(self)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        sidebarItem.regularTitle = "Location"
        sidebarItem.compactTitle = "Location"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.location)!
        sidebarItem.color = .red
    }
    
    override open func construct(builder: FormBuilder) {
        // check creative for this
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .green : .red
    }
}

public class DefaultLocationReport: Reportable {
    
    var eventLocation: CodableLocation?
    
    public weak var event: Event?
    public var evaluator: Evaluator = Evaluator()
    
    public required init(event: Event) {
        self.event = event
        
        evaluator.addObserver(event)
        // no validation yet!
    }
    
    // Codable
    
    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        eventLocation = try container.decode(CodableLocation.self, forKey: .eventLocation)
    }
    
    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(eventLocation, forKey: .eventLocation)
    }
    
    enum Keys: String, CodingKey {
        case eventLocation = "eventLocation"
    }
    
    // Evaluation
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}

// wrapping CLLocation in a `Codable` struct
struct CodableLocation: Codable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let altitude: CLLocationDistance
    let horizontalAccuracy: CLLocationAccuracy
    let verticalAccuracy: CLLocationAccuracy
    let speed: CLLocationSpeed
    let course: CLLocationDirection
    let timestamp: Date
}

extension CLLocation {
    convenience init(model: CodableLocation) {
        self.init(coordinate: CLLocationCoordinate2DMake(model.latitude, model.longitude), altitude: model.altitude, horizontalAccuracy: model.horizontalAccuracy, verticalAccuracy: model.verticalAccuracy, course: model.course, speed: model.speed, timestamp: model.timestamp)
    }
}
