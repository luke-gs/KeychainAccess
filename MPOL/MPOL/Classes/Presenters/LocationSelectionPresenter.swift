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

    private func confirmAndCompleteSelection(_ selectedLocation: LocationSelectionType, viewController: UIViewController, completionHandler: ((LocationSelectionType?) -> Void)?) {

        // Present the confirmation screen, and when it is done, close all pushed views and call the completion handler
        Director.shared.present(LocationSelectionScreen.locationSelectionFinal(selectedLocation, completionHandler: { updatedSelectedLocation in
            // Pop to view controller before this one, regardless of whether there are more VCs on stack
            if let viewControllers = viewController.navigationController?.viewControllers,
                let index = viewControllers.firstIndex(of: viewController) {
                let previousVC = viewControllers[index - 1]
                viewController.navigationController?.popToViewController(previousVC, animated: true)
            }
            completionHandler?(updatedSelectedLocation)
        }), fromViewController: viewController)

    }

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! LocationSelectionScreen

        switch presentable {

        case .locationSelectionLanding(let selectedLocation, let completionHandler):

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
                self?.confirmAndCompleteSelection(selectedLocation, viewController: viewController, completionHandler: completionHandler)
            }

            viewController.cancelHandler = { [weak viewController] in
                completionHandler?(nil)
                viewController?.navigationController?.popViewController(animated: true)
            }

            // Special modalPresentationStyle for form item to use push during presentation
            viewController.modalPresentationStyle = .none

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
            let viewModel = LocationSelectionConfirmationViewModel(locationSelection: selectedLocation, isEditable: true)
            viewModel.streetTypeOptions = StreetType.all.map { return AnyPickable($0) }
            viewModel.stateOptions = StateType.all.map { return AnyPickable($0) }
            viewModel.suburbOptions = [AnyPickable("Collingwood"), AnyPickable("Fitzory"), AnyPickable("Carlton")]
            viewModel.typeOptions = [AnyPickable("Event Location")]
            viewModel.typeTitle = NSLocalizedString("Involvement/s", comment: "")

            let viewController = LocationSelectionConfirmationViewController(viewModel: viewModel)
            viewController.doneHandler = { _ in
                // Do not pop this view controller, will be double/triple popped by locationSelectionLanding handler
                completionHandler?(selectedLocation)
            }
            return viewController
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        // Push within existing modal navigation for all screens
        from.navigationController?.pushViewController(to, animated: true)
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is LocationSelectionScreen.Type
    }
}
