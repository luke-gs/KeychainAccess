//
//  TasksListIncidentViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TasksListIncidentViewModel: TasksListItemViewModel {
    public let priority: String?
    public let description: String?
    public let resources: [TasksListInformationRowViewModel]?

    public var badgeText: String? {
        return priority
    }
    
    public var hasResources: Bool {
        return resources?.count ?? 0 > 0
    }
    
    public let badgeTextColor: UIColor?
    public let badgeFillColor: UIColor?
    public let badgeBorderColor: UIColor?
    public var hasUpdates: Bool
    
    public init(identifier: String, title: String, subtitle: String, caption: String, priority: String? = nil,
                description: String? = nil, resources: [TasksListInformationRowViewModel]? = nil, badgeTextColor: UIColor?,
                badgeFillColor: UIColor?, badgeBorderColor: UIColor?, hasUpdates: Bool)
    {
        self.description = description
        self.resources = resources
        self.priority = priority
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.hasUpdates = hasUpdates
        
        super.init(identifier: identifier, title: title, subtitle: subtitle, caption: caption)
    }
    
    public convenience init(incident: SyncDetailsIncident, showsDescription: Bool = true, showsResources: Bool = true, hasUpdates: Bool) {
        let resources = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier).map {
            return TasksListInformationRowViewModel(with: $0)
        }
        
        self.init(
            identifier: incident.identifier,
            title: [incident.type, incident.resourceCountString].joined(),
            subtitle: incident.location.fullAddress,
            caption: [incident.identifier, incident.secondaryCode].joined(separator: " • "),
            priority: incident.grade.rawValue,
            description: showsDescription ? incident.details : nil,
            resources: showsResources ? resources : nil,
            badgeTextColor: incident.grade.badgeColors.text,
            badgeFillColor: incident.grade.badgeColors.fill,
            badgeBorderColor: incident.grade.badgeColors.border,
            hasUpdates: hasUpdates)
    }
}
