//
//  TrafficStopPresenter.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit
import PromiseKit

public class TrafficStopPresenter: Presenter {

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! TrafficStopScreen

        switch presentable {

        case .trafficStopCreate(let completionHandler):

            // Likely from manifest in real client
            let priorityOptions = CADClientModelTypes.incidentGrade.allCases.map { AnyPickable($0.rawValue) }
            let primaryCodeOptions = ["Traffic", "Crash", "Other"].map { AnyPickable($0) }
            let secondaryCodeOptions = ["Traffic", "Crash", "Other"].map { AnyPickable($0) }

            let viewModel = CreateTrafficStopViewModel(priorityOptions: priorityOptions,
                                                       primaryCodeOptions: primaryCodeOptions,
                                                       secondaryCodeOptions: secondaryCodeOptions,
                                                       currentLocationGenerator: { return LocationSelectionCore.reverseGeocode() })

            let viewController = CreateTrafficStopViewController(viewModel: viewModel)
            viewController.submitHandler = { viewModel in
                // TODO: send to network
                return Promise<Void>()
            }
            viewController.closeHandler = { [weak viewController] submitted in
                // Close UI and call completion handler
                viewController?.navigationController?.popViewController(animated: true)
                completionHandler?(submitted ? viewModel : nil)
            }
            return viewController

        case .trafficStopAddEntity(let completionHandler):
            let viewModel = RecentEntitySummarySelectionViewModel()
            viewModel.allowedEntityTypes = [Person.self, Vehicle.self]

            let viewController = EntitySummarySelectionViewController(viewModel: viewModel)
            viewController.selectionHandler = { [weak viewController] entity in
                // Close UI and call completion handler
                viewController?.navigationController?.popViewController(animated: true)
                completionHandler?(entity)
            }
            return viewController
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! TrafficStopScreen

        switch presentable {

        // Push within existing modal
        case .trafficStopCreate, .trafficStopAddEntity:
            from.navigationController?.pushViewController(to, animated: true)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is  TrafficStopScreen.Type
    }
}
