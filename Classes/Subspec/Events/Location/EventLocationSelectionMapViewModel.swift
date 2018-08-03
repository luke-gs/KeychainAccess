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

/// Delegate for events location selection view model
public protocol EventLocationSelectionMapViewModelDelegate: class {
    func didSelectLocation(_ location: EventLocation?)
}

open class EventLocationSelectionMapViewModel: LocationSelectionMapViewModel, Evaluatable {

    /// Delegate for selection changes
    /// Note: Additional delegate is needed as Events LocationAction does not use closures for action value changes
    public weak var eventDelegate: EventLocationSelectionMapViewModelDelegate?

    public var evaluator: Evaluator = Evaluator()

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
