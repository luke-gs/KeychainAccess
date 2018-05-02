//
//  TrafficInfringementScreenBuilder..swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class TrafficInfringementScreenBuilder: IncidentScreenBuilding {

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
        case let report as TrafficInfringementEntitiesReport:
            let viewModel = TrafficInfringementEntitiesViewModel(report: report)
            return TrafficInfringementEntitiesViewController(viewModel: viewModel)
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


