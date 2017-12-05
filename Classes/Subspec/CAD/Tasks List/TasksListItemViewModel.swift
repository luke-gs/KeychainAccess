//
//  TasksListItemViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class TasksListItemViewModel {
    public let identifier: String
    public let title: String
    public let subtitle: String
    public let caption: String
    public let priority: String?
    public let description: String?
    public let resources: [TasksListItemResourceViewModel]?

    public var badgeText: String? {
        return priority
    }
    
    public let badgeTextColor: UIColor?
    public let badgeFillColor: UIColor?
    public let badgeBorderColor: UIColor?
    public var hasUpdates: Bool
    
    public init(identifier: String, title: String, subtitle: String, caption: String, priority: String? = nil, description: String? = nil, resources: [TasksListItemResourceViewModel]? = nil, badgeTextColor: UIColor?, badgeFillColor: UIColor?, badgeBorderColor: UIColor?, hasUpdates: Bool) {
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.description = description
        self.resources = resources
        self.priority = priority
        self.badgeTextColor = badgeTextColor
        self.badgeFillColor = badgeFillColor
        self.badgeBorderColor = badgeBorderColor
        self.hasUpdates = hasUpdates
    }

    public convenience init(incident: SyncDetailsIncident, hasUpdates: Bool) {
        self.init(
            identifier: incident.identifier,
            title: [incident.type, incident.resourceCountString].removeNils().joined(separator: " "),
            subtitle: incident.location.fullAddress,
            caption: [incident.identifier, incident.secondaryCode].removeNils().joined(separator: " • "),
            priority: incident.grade.rawValue,
            description: incident.details,
            resources: nil, // TODO: Get resources
            badgeTextColor: incident.grade.badgeColors.text,
            badgeFillColor: incident.grade.badgeColors.fill,
            badgeBorderColor: incident.grade.badgeColors.border,
            hasUpdates: hasUpdates)
    }

    public convenience init(resource: SyncDetailsResource, incident: SyncDetailsIncident?, hasUpdates: Bool) {
        self.init(
            identifier: resource.callsign,
            title: [resource.callsign, resource.officerCountString].removeNils().joined(separator: " "),
            subtitle: resource.location.suburb,
            caption: resource.status.title,
            priority: incident?.grade.rawValue,
            description: incident?.details,
            badgeTextColor: incident?.grade.badgeColors.text,
            badgeFillColor: incident?.grade.badgeColors.fill,
            badgeBorderColor: incident?.grade.badgeColors.border,
            hasUpdates: hasUpdates)
    }
}
