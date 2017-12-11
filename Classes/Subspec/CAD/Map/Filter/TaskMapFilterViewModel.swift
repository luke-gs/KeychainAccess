//
//  TaskMapFilterViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TaskMapFilterViewModel: MapFilterViewModel {
    
    public var sections: [MapFilterSection] = []
    
    public let defaultSections: [MapFilterSection] = [
        MapFilterSection(title: "General", isOn: nil, toggleRows: [
            MapFilterToggleRow(options: [
                MapFilterOption(text: "Show results outside my Patrol Area", isOn: false)
            ])
        ]),
        
        MapFilterSection(title: "Incidents", isOn: true, toggleRows: [
            MapFilterToggleRow(title: "Priority", options: [
                MapFilterOption(text: "P1", isEnabled: false, isOn: true),
                MapFilterOption(text: "P2", isOn: true),
                MapFilterOption(text: "P3", isOn: true),
                MapFilterOption(text: "P4", isOn: true),
            ]),
            
            MapFilterToggleRow(title: "Show incidents that are", options: [
                MapFilterOption(text: "Resourced", isOn: true),
                MapFilterOption(text: "Unresourced", isOn: true),
            ]),
        ]),
        
        MapFilterSection(title: "Patrol", isOn: true),
        
        MapFilterSection(title: "Broadcasts", isOn: true),
        
        MapFilterSection(title: "Resources", isOn: true, toggleRows: [
            MapFilterToggleRow(title: "Show resources that are", options: [
                MapFilterOption(text: "Tasked", isOn: true),
                MapFilterOption(text: "Untasked", isOn: true),
            ]),
        ])
    ]
    
    /// Indexes for sections. Manually mapped, update if you change something.
    private struct Indexes {
        static let general = 0
        static let incidents = 1
        static let patrol = 2
        static let broadcasts = 3
        static let resources = 4
        
        /// Indexes for toggle rows
        struct ToggleRows {
            static let patrolArea = 0
            static let incidentsPriority = 0
            static let incidentsResourced = 1
            static let resourcesTasked = 0
        }
    }
    
    public init() {
        sections = defaultSections.copy()
    }
    
    // MARK: - Filter
    
    public func reset() {
        sections = defaultSections.copy()
    }
    
    // MARK: General
    
    /// Whether to show results outside the patrol area
    public var showResultsOutsidePatrolArea: Bool {
        return sections[Indexes.general].toggleRows[Indexes.ToggleRows.patrolArea].options[0].isOn
    }
    
    // MARK: Incidents
    
    /// Whether to show incidents
    public var showIncidents: Bool {
        return sections[Indexes.incidents].isOn.isTrue
    }
    
    /// Which priorities to show
    public var priorities: [IncidentGrade] {
        let options = sections[Indexes.incidents].toggleRows[Indexes.ToggleRows.incidentsPriority].options
        
        return (options.map { option in
            if option.isOn, let text = option.text {
                return IncidentGrade(rawValue: text)
            }
            return nil
        } as [IncidentGrade?]).removeNils()
    }
    
    /// Which type of incidents to show
    public var resourcedIncidents: [SyncDetailsIncident.Status] {
        let options = sections[Indexes.incidents].toggleRows[Indexes.ToggleRows.incidentsResourced].options
        
        return (options.map { option in
            if option.isOn, let text = option.text {
                return SyncDetailsIncident.Status(rawValue: text)
            }
            return nil
        } as [SyncDetailsIncident.Status?]).removeNils()
    }
    
    // MARK: Patrol
    
    /// Whether to show patrol
    public var showPatrol: Bool {
        return sections[Indexes.patrol].isOn.isTrue
    }
    
    // MARK: Broadcasts
    
    /// Whether to show broadcasts
    public var showBroadcasts: Bool {
        return sections[Indexes.broadcasts].isOn.isTrue
    }
    
    // MARK: Resources
    
    /// Whether to show resources
    public var showResources: Bool {
        return sections[Indexes.resources].isOn.isTrue
    }
    
    /// Which type of resources to show
    public var taskedResources: (tasked: Bool, untasked: Bool) {
        let options = sections[Indexes.resources].toggleRows[Indexes.ToggleRows.resourcesTasked].options
        let tasked = options[0].isOn
        let untasked = options[1].isOn
        
        return (tasked, untasked)
    }
    
    // MARK: - View controller info
    
    public func createViewController(delegate: MapFilterViewControllerDelegate?) -> UIViewController {
        let viewController = MapFilterViewController(viewModel: self)
        viewController.delegate = delegate
        return viewController
    }
    
    public func createViewController() -> UIViewController {
        return MapFilterViewController(viewModel: self)
    }
    
    public func titleText() -> String? {
        return NSLocalizedString("Filter Tasks", comment: "")
    }
    
    public func footerButtonText() -> String? {
        return NSLocalizedString("Reset Filter", comment: "")
    }
    
    public func disablesCheckboxesOnSectionDisabled(for section: Int) -> Bool {
        return false
    }

}
