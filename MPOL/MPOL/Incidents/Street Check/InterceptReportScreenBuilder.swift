//
//  InterceptReportScreenBuilder.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class InterceptReportScreenBuilder: IncidentScreenBuilding {

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
        case let report as DefaultEntitiesListReport:
            return DefaultEntitiesListViewController(viewModel: DefaultEntitiesListViewModel(report: report))
        case let report as InterceptReportGeneralDetailsReport:
            return InterceptReportGeneralDetailsViewController(viewModel: InterceptReportGeneralDetailsViewModel(report: report))
        default:
            fatalError("No ViewController found for reportable: \(report.self)")
        }
    }

    public init() {}
}



