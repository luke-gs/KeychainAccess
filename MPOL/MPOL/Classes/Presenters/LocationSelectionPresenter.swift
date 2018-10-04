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
                completionHandler?(selectedLocation)
                viewController?.navigationController?.popViewController(animated: true)
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
            viewController.selectionHandler = { [weak viewController] selectedLocation in
                completionHandler?(selectedLocation)
                viewController?.navigationController?.popViewController(animated: true)
            }
            return viewController

        case .locationSelectionFinal(_, let completionHandler):
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
