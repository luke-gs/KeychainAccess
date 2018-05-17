//
//  DomesticViolenceScreenBuilder.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class DomesticViolenceScreenBuilder: IncidentScreenBuilding {

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
        case let report as DefaultEntitiesListReport:
            return DefaultEntitiesListViewController(viewModel: DefaultEntitiesListViewModel(report: report))
        case let report as DomesticViolencePropertyReport:
            return DomesticViolencePropertyViewController(viewModel: DomesticViolencePropertyViewModel(report: report))
        case let report as DomesticViolenceGeneralDetailsReport:
            return DomesticViolenceGeneralDetailsViewController(viewModel: DomesticViolenceGeneralDetailsViewModel(report: report))
        default:
            fatalError("No ViewController found for reportable: \(report.self)")
        }
    }

    public init() {}
}
