//
//  EventLocationSelectionMapViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import PromiseKit

public extension EvaluatorKey {
    static let locationType = EvaluatorKey(rawValue: "locationType")
}

open class EventLocationSelectionMapViewModel: LocationSelectionMapViewModel, Evaluatable {

    public var evaluator: Evaluator = Evaluator()

    /// The last saved location
    public var savedLocation: EventLocation? = nil

    /// Create new event location object based on current state of viewModel
    public var eventLocation: EventLocation? {
        if let coordinate = location?.coordinate {
            return EventLocation(coordinate: coordinate, addressString: location?.addressString)
        }
        return nil
    }

    /// Constructor
    public override init(location: LocationSelection? = nil, typeCollection: ManifestCollection? = nil) {
        super.init(location: location, typeCollection: typeCollection)

        evaluator.registerKey(.locationType) { [weak self] () -> (Bool) in
            return (self?.isValid).isTrue
        }
    }

    // MARK: - EvaluationObserverable
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {}
}
