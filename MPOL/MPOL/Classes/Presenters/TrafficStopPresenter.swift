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

        case .trafficStopSearchEntity:
            // Will redirect to search, return dummy VC here
            return UIViewController()
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! TrafficStopScreen

        switch presentable {

        // Push within existing modal
        case .trafficStopCreate(_), .trafficStopAddEntity(_):
            from.navigationController?.pushViewController(to, animated: true)

        // Search app
        case .trafficStopSearchEntity:
            // Dismiss current modal and go to search tab
            from.dismiss(animated: true) {
                let activity = SearchActivity.searchEntity(term: Searchable(text: "", type: "Vehicle"), shouldSearchImmediately: false)
                do {
                    try SearchActivityLauncher.default.launch(activity, using: AppURLNavigator.default)
                }  catch {
                    AlertQueue.shared.addSimpleAlert(title: "An Error Has Occurred", message: "Failed To Launch Entity Search")
                }
            }

        // Default presentation, based on container class (eg push if in navigation controller)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is  TrafficStopScreen.Type
    }
}


