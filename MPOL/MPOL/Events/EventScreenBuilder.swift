//
//  EventScreenBuilder.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 31/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class EventScreenBuilder: EventScreenBuilding {

    var incidentsManager: IncidentsManager?

    public func viewControllers(for reportables: [Reportable]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        for report in reportables {
            viewControllers.append(viewController(for: report))
        }

        return viewControllers
    }

    private func viewController(for report: Reportable) -> UIViewController {
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
            let manager = incidentsManager ?? IncidentsManager()

            // Add IncidentBuilders here
            manager.add(InfringementIncidentBuilder(), for: .infringementNotice)
            manager.add(StreetCheckIncidentBuilder(), for: .streetCheck)

            return IncidentListViewController(viewModel: IncidentListViewModel(report: report, incidentsManager: manager))
        default:
            fatalError("No ViewController found for reportable: \(report.self)")
        }
    }

    public init() { }
}

