//
//  EventScreenBuilder.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

public class EventScreenBuilder: EventScreenBuilding {

    var incidentsManager: IncidentsManager!

    public func viewControllers(for reportables: [EventReportable]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        for report in reportables {
            viewControllers.append(viewController(for: report))
        }

        return viewControllers
    }

    private func viewController(for report: EventReportable) -> UIViewController {
        switch report {
        case let report as DefaultDateTimeReport:
            return DefaultEventDateTimeViewController(viewModel: DefaultDateTimeViewModel(report: report))
        case let report as DefaultLocationReport:
            return DefaultEventLocationViewController(viewModel: DefaultEventLocationViewModel(report: report))
        case let report as OfficerListReport:
            return DefaultEventOfficerListViewController(viewModel: EventOfficerListViewModel(report: report))
        case let report as DefaultNotesMediaReport:
            return DefaultEventNotesMediaViewController(viewModel: DefaultEventNotesMediaViewModel(report: report))
        case let report as IncidentListReport:
            report.incidents.forEach { incidentsManager.add(incident: $0) }
            return IncidentListViewController(viewModel: IncidentListViewModel(report: report, incidentsManager: incidentsManager))
        case let report as EventEntitiesListReport:
            return EventEntitiesListViewController(viewModel: EventEntitiesListViewModel(report: report))
        default:
            fatalError("No ViewController found for reportable: \(report.self)")
        }
    }

    public init() {}
}
