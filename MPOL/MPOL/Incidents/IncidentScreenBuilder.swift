//
//  IncidentScreenBuilder.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class IncidentScreenBuilder: IncidentScreenBuilding {

    public func viewControllers(for reportables: [Reportable]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        for report in reportables {
            if let viewController = viewController(for: report) {
                viewControllers.append(viewController)
            }
        }

        return viewControllers
    }

    private func viewController(for report: Reportable) -> UIViewController? {
        switch report {
        case let report as DefaultDateTimeReport:
            return DefaultEventDateTimeViewController(report: report)
        case let report as DefaultLocationReport:
            return DefaultEventLocationViewController(report: report)
        case let report as OfficerListReport:
            return DefaultEventOfficerListViewController(viewModel: EventOfficerListViewModel(report: report))
        case let report as DefaultNotesPhotosReport:
            return DefaultEventNotesPhotosViewController(report: report)
        case let report as IncidentListReport:
            return IncidentListViewController(viewModel: IncidentListViewModel(report: report))
        default:
            return nil
        }
    }

    public init() { }
}


