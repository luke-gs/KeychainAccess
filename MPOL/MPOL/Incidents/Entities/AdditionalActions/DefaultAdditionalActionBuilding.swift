//
//  DefaultAdditionalActionBuilding.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class DefaultAdditionalActionBuilding: AdditionalActionBuilding {

    public func createAdditionalAction(for type: AdditionalActionType, on incident: Incident) -> AdditionalAction {

        return AdditionalAction(incident: incident, type: .vehicleTow)
    }
}

public class DefaultAdditionalActionScreenBuilding: AdditionalActionScreenBuilding {

    public func viewControllers(for reports: [Reportable]) -> [UIViewController] {

        var viewControllers = [UIViewController]()
        reports.forEach{
            switch $0 {
            case is PersonSearchReport:
                let viewModel = PersonSearchReportViewModel(report: $0 as! PersonSearchReport)
                 viewControllers.append(PersonSearchReportViewController(viewModel: viewModel))
            case is VehicleTowReport:
                let viewModel = VehicleTowReportViewModel(report: $0 as! VehicleTowReport)
                viewControllers.append(VehicleTowReportViewController(viewModel: viewModel))
            default:
                fatalError("Invalid Report")
            }
        }
        return viewControllers
    }
}
