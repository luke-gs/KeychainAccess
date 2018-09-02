//
//  TrafficInfringementScreenBuilder..swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

public class TrafficInfringementScreenBuilder: IncidentScreenBuilding {

    public func viewControllers(for reportables: [IncidentReportable]) -> [UIViewController] {
        var viewControllers = [UIViewController]()

        for report in reportables {
            if let viewController = viewController(for: report) {
                viewControllers.append(viewController)
            }
        }

        return viewControllers
    }

    private func viewController(for report: IncidentReportable) -> UIViewController? {

        switch report {
        case let report as DefaultEntitiesListReport:
            let viewModel = DefaultEntitiesListViewModel(report: report, incidentType: .trafficInfringement)
            return DefaultEntitiesListViewController(viewModel: viewModel)
        case let report as TrafficInfringementOffencesReport:
            return TrafficInfringementOffencesViewController(viewModel: TrafficInfringementOffencesViewModel(report: report))
        case let report as TrafficInfringementServiceReport:
            return TrafficInfringementServiceViewController(viewModel: TrafficInfringementServiceViewModel(report: report))
        default:
            fatalError("No ViewController found for reportable: \(report.self)")
        }
    }

    public init() {}
}


