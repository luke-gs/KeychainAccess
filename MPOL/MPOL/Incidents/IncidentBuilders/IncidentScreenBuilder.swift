//
//  IncidentScreenBuilder.swift
//  MPOLKit
//
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

        //TODO: Remove non-incident reports from here and replace with actual incident reports
        switch report {
        case let report as IncidentTestReport:
            return IncidentTestViewController(report: report)
        default:
            fatalError("No ViewController found for reportable: \(report.self)")
        }
    }

    public init() {}
}


