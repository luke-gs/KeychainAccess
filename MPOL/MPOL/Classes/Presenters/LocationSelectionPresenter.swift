//
//  LocationSelectionPresenter.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PromiseKit

public class LocationSelectionPresenter: Presenter {

    // MARK: - PUBLIC

    /// Workflow id for events
    public static let eventWorkflowId = "event"

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! LocationSelectionScreen

        switch presentable {

        case .locationSelectionLanding(let workflowId, let selectedLocation, let completionHandler):

            self.workflowId = workflowId

            // Create view model with closure for typeahead search
            let viewModel = LocationSelectionLandingViewModel(locationSelectionType: LocationSelectionCore.self, selectedLocation: nil) { (searchText, cancelToken) -> Promise<[MPOLKitEntityProtocol]> in
                return APIManager.shared.typeAheadSearchAddress(in: MPOLSource.gnaf, with: LookupAddressSearchRequest(searchText: searchText), withCancellationToken: cancelToken).mapValues {
                    return $0
                }
            }
            viewModel.selectedLocation = selectedLocation

            let viewController = LocationSelectionLandingViewController(viewModel: viewModel)
            viewController.selectionHandler = { [weak self, weak viewController] selectedLocation in
                guard let `viewController` = viewController else { return }

                // Present the confirmation screen, and when it is done, close all pushed views and call the completion handler
                Director.shared.present(LocationSelectionScreen.locationSelectionFinal(selectedLocation, completionHandler: { updatedSelectedLocation in
                    self?.unwindViewController(viewController)
                    completionHandler?(updatedSelectedLocation)
                }), fromViewController: viewController)
            }

            viewController.mapHandler = { [weak viewController] in
                guard let `viewController` = viewController else { return }

                // Present the full map
                Director.shared.present(LocationSelectionScreen.locationSelectionMap(viewModel.selectedLocation, completionHandler: { selectedLocation in
                    if let selectedLocation = selectedLocation {
                        viewController.selectionHandler?(selectedLocation)
                    }
                }), fromViewController: viewController)
            }

            viewController.cancelHandler = { [weak self, weak viewController] in
                guard let `viewController` = viewController else { return }
                self?.unwindViewController(viewController)
                completionHandler?(nil)
            }

            // Remove text for back button in next screens
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

            return viewController

        case .locationSelectionMap(let selectedLocation, let completionHandler):
            let viewModel = LocationSelectionFullMapViewModel(locationSelectionType: LocationSelectionCore.self)
            viewModel.selectedLocation = selectedLocation

            let viewController = LocationSelectionFullMapViewController(viewModel: viewModel)
            viewController.selectionHandler = { selectedLocation in
                // Do not pop this view controller, will be double/triple popped by locationSelectionLanding handler
                completionHandler?(selectedLocation)
            }

            // Remove text for back button in next screens
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

            return viewController

        case .locationSelectionFinal(let selectedLocation, let completionHandler):
            let viewModel = LocationSelectionConfirmationViewModel(locationSelection: selectedLocation)
            viewModel.streetTypeOptions = StreetType.all.map { return AnyPickable($0) }
            viewModel.stateOptions = StateType.all.map { return AnyPickable($0) }
            viewModel.suburbOptions = [AnyPickable("Collingwood"), AnyPickable("Fitzory"), AnyPickable("Carlton")]

            if workflowId == LocationSelectionPresenter.eventWorkflowId {
                // Add location type to final confirmation screen
                if let manifestItems = Manifest.shared.entries(for: ManifestCollection.eventLocationInvolvementType) {
                    viewModel.typeTitle = NSLocalizedString("Involvement/s", comment: "")
                    viewModel.typeOptions = manifestItems.map { AnyPickable(PickableManifestEntry($0)) }
                }

                // Address components are editable if not from GNAF lookahead search, and required
                if let selectedLocation = selectedLocation as? LocationSelectionCore, selectedLocation.searchResult == nil {
                    viewModel.isEditable = true
                    viewModel.requiredFields = true
                }
            } else {
                viewModel.isEditable = true
            }

            let viewController = LocationSelectionConfirmationViewController(viewModel: viewModel)
            viewController.doneHandler = { _ in
                // Do not pop this view controller, will be double/triple popped by locationSelectionLanding handler
                completionHandler?(selectedLocation)
            }
            return viewController
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {

        // Check if coming from modal dialog
        if let nav = from.navigationController as? ModalNavigationController {
            // Push within existing modal navigation
            nav.pushViewController(to, animated: true)
        } else {
            // Present in a modal form sheet from split view (to get centered popover)
            let parent = from.pushableSplitViewController ?? from
            let container = ModalNavigationController(rootViewController: to)
            parent.present(container, size: CGSize(width: 512, height: 700))
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is LocationSelectionScreen.Type
    }

    // MARK: - PRIVATE

    /// The ID of the current location selection workflow
    private var workflowId: String?

    /// Unwind the presentation of the location selection view controllers
    private func unwindViewController(_ viewController: UIViewController) {

        guard let viewControllers = viewController.navigationController?.viewControllers,
            let index = viewControllers.firstIndex(of: viewController) else { return }

        // Check whether we are first item in navigation stack and presented
        if let presenting = viewController.presentingViewController, index == 0 {
            // Dismiss presented container
            presenting.dismiss(animated: true, completion: nil)
        } else {
            // Pop to view controller before this one in one smooth animation, regardless of how many pushed VCs
            let previousVC = viewControllers[index - 1]
            viewController.navigationController?.popToViewController(previousVC, animated: true)
        }
    }

}
