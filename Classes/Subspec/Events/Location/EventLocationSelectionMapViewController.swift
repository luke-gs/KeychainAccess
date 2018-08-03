//
//  LocationMapSelectViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class EventLocationSelectionMapViewController: LocationSelectionMapViewController, EvaluationObserverable {

    public var eventViewModel: EventLocationSelectionMapViewModel {
        return viewModel as! EventLocationSelectionMapViewModel
    }

    public override init(viewModel: LocationSelectionMapViewModel, layout: MapFormBuilderViewLayout? = StackMapLayout()) {
        super.init(viewModel: viewModel, layout: layout)
        eventViewModel.evaluator.addObserver(self)

        // Events LocationAction does not use closures for action value changes,
        // so forward selection to delegate and handle dismissal
        self.cancelHandler = { [weak self] in
            viewModel.location = nil
            self?.navigationController?.popViewController(animated: true )
        }

        self.selectionHandler = { [weak self] _ in
            if let coordinate = viewModel.coordinate, let addressString = viewModel.location?.addressString {
                let eventLocation = EventLocation(coordinate: coordinate, addressString: addressString)
                self?.eventViewModel.eventDelegate?.didSelectLocation(eventLocation)
                self?.dismiss(animated: true)
            }
        }
    }

    deinit {
        eventViewModel.evaluator.removeObserver(self)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        if key == .locationType {
            navigationItem.rightBarButtonItem?.isEnabled = evaluationState
        }
    }
}
