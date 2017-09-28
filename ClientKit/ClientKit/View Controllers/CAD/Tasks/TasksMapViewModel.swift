//
//  TasksMapViewModel.swift
//  ClientKit
//
//  Created by Kyle May on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import CoreLocation

// MARK: - Dummy models

// TODO: Remove these

struct IncidentDummyMapModel {
    var identifier: String
    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
    var priority: Priority
    var assigned: Bool
    
    var usesDarkBackground: Bool {
        return !assigned
    }
    
    enum Priority: CustomStringConvertible {
        case p1
        case p2
        case p3
        case p4
        
        var description: String {
            switch self {
            case .p1: return "P1"
            case .p2: return "P2"
            case .p3: return "P3"
            case .p4: return "P4"
            }
        }
        
        var color: UIColor {
            switch self {
            case .p1:
                return UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
            case .p2:
                return UIColor(red: 255.0 / 255.0, green: 204.0 / 255.0, blue: 0.0, alpha: 1.0)
            case .p3:
                return UIColor(red: 0.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            case .p4:
                return UIColor(red: 0.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            }
        }
        
        var showsFilledColor: Bool {
            switch self {
            case .p1, .p2:
                return true
            case .p3, .p4:
                return false
            }
        }
    }
}

struct PatrolDummyMapModel {
    var identifier: String
    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
}

struct BroadcastDummyMapModel {
    var identifier: String
    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
}

struct ResourceDummyMapModel {
    var identifier: String
    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
    var resource: Resource
    var state: State
    
    enum Resource {
        case copper
        case car
        case plane
        case boat
        case bike
        case segway
        case doggo
        
        var image: UIImage? {
            switch self {
            case .copper:
                return AssetManager.shared.image(forKey: .entityOfficer)
            case .car:
                return AssetManager.shared.image(forKey: .resourceCar)
            case .plane:
                return AssetManager.shared.image(forKey: .resourceAir)
            case .boat:
                return AssetManager.shared.image(forKey: .resourceWater)
            case .bike:
                return AssetManager.shared.image(forKey: .resourceBicycle)
            case .segway:
                return AssetManager.shared.image(forKey: .resourceSegway)
            case .doggo:
                return AssetManager.shared.image(forKey: .resourceDog)
                
            }
        }
    }
    
    enum State {
        case unassigned
        case assigned
        case tasked
        case duress
        
        var color: UIColor {
            switch self {
            case .unassigned:
                return UIColor(red: 76.0 / 255.0, green: 175.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
            case .assigned, .tasked:
                return #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
            case .duress:
                return UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
            }
        }
    }
}

class TasksMapViewModel {

    // MARK: - Data Source
    
    private var incidents: [IncidentDummyMapModel] = []
    private var patrol: [PatrolDummyMapModel] = []
    private var broadcast: [BroadcastDummyMapModel] = []
    private var resources: [ResourceDummyMapModel] = []
    
    // MARK: - Filter
    
    /// Filters for annotations data source
    struct Filter: OptionSet {
        let rawValue: Int
        
        static let incidents = Filter(rawValue: 1 << 0)
        static let patrol    = Filter(rawValue: 1 << 1)
        static let broadcast = Filter(rawValue: 1 << 2)
        static let resources = Filter(rawValue: 1 << 3)
    }
    
    var filter: Filter = [.incidents, .patrol, .broadcast, .resources]

    // MARK: - Annotations

    /// Annotations matching the current filter
    var filteredAnnotations: [TaskAnnotation] {
        /// Annotations of the incidents type
        let incidentsAnnotations = incidents.map { model in
            return IncidentAnnotation(identifier: model.identifier,
                                      coordinate: model.coordinate,
                                      title: model.title,
                                      subtitle: model.subtitle,
                                      iconText: String(describing: model.priority),
                                      iconColor: model.priority.color,
                                      iconFilled: model.priority.showsFilledColor,
                                      usesDarkBackground: model.usesDarkBackground)
        }
        
        /// Annotations of the patrol type
        let patrolAnnotations = patrol.map { model in
            return TaskAnnotation(identifier: model.identifier,
                                          coordinate: model.coordinate,
                                          title: model.title,
                                          subtitle: model.subtitle)
        }
        
        /// Annotations of the broadcast type
        let broadcastAnnotations = broadcast.map { model in
            return TaskAnnotation(identifier: model.identifier,
                                          coordinate: model.coordinate,
                                          title: model.title,
                                          subtitle: model.subtitle)
        }
        
        /// Annotations of the resource type
        let resourceAnnotations = resources.map { model in
            return ResourceAnnotation(identifier: model.identifier,
                                          coordinate: model.coordinate,
                                          title: model.title,
                                          subtitle: model.subtitle,
                                          icon: model.resource.image,
                                          iconBackgroundColor: model.state.color,
                                          blinking: model.state == .duress)
        }
        
        var annotations: [TaskAnnotation] = []
        
        if filter.contains(.incidents) {
            annotations += incidentsAnnotations as [TaskAnnotation]
        }
        
        if filter.contains(.patrol) {
            annotations += patrolAnnotations
        }
        
        if filter.contains(.broadcast) {
            annotations += broadcastAnnotations
        }
        
        if filter.contains(.resources) {
            annotations += resourceAnnotations  as [TaskAnnotation]
        }
        
        return annotations
    }
    
    // MARK: - Debug
    
    func loadDummyData() {
        incidents = [
            IncidentDummyMapModel(identifier: "i1", title: "Assult", subtitle: "Resourced (2)", coordinate: CLLocationCoordinate2D(latitude: -37.803258, longitude: 144.983707), priority: .p1, assigned: true),
            IncidentDummyMapModel(identifier: "i2", title: "Domestic Violence", subtitle: "Assigned", coordinate: CLLocationCoordinate2D(latitude: -37.808173, longitude: 144.978827), priority: .p2, assigned: true),
            IncidentDummyMapModel(identifier: "i3", title: "Trespassing", subtitle: "Assigned", coordinate: CLLocationCoordinate2D(latitude: -37.797528, longitude: 144.985450), priority: .p3, assigned: true),
            IncidentDummyMapModel(identifier: "i4", title: "Vandalism", subtitle: "Unassigned", coordinate: CLLocationCoordinate2D(latitude: -37.802048, longitude: 144.987646), priority: .p4, assigned: false),
        ]
        
        patrol = [
        ]
        
        broadcast = [
        ]
        
        resources = [
            ResourceDummyMapModel(identifier: "r1", title: "P03", subtitle: "(3)", coordinate: CLLocationCoordinate2D(latitude: -37.807014, longitude: 144.973212), resource: .car, state: .duress),
            ResourceDummyMapModel(identifier: "r2", title: "P07", subtitle: "(2)", coordinate: CLLocationCoordinate2D(latitude: -37.802314, longitude: 144.975459), resource: .car, state: .unassigned),
            ResourceDummyMapModel(identifier: "r3", title: "P07", subtitle: "(2)", coordinate: CLLocationCoordinate2D(latitude: -37.799788, longitude: 144.992054), resource: .doggo, state: .assigned),
            //-37.809426, 144.990656
        ]
    }
}
