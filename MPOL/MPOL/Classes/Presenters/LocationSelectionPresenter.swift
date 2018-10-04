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
            viewController.selectionHandler = { [weak viewController] selectedLocation in
                guard let `viewController` = viewController else { return }
                completionHandler?(selectedLocation)

                // Pop to view controller before this one, regardless of whether there are more VCs on stack
                if let viewControllers = viewController.navigationController?.viewControllers,
                    let index = viewControllers.firstIndex(of: viewController) {
                    let previousVC = viewControllers[index - 1]
                    viewController.navigationController?.popToViewController(previousVC, animated: true)
                }
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
                // Do not pop this view controller, will be double popped by locationSelectionLanding handler
                completionHandler?(selectedLocation)
            }
            return viewController

        case .locationSelectionFinal(_, _):
            MPLUnimplemented()
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
