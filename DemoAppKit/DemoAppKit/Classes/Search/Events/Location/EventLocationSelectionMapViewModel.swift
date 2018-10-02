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

open class EventLocationSelectionMapViewModel: OldLocationSelectionMapViewModel, Evaluatable {

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
    public override init(location: OldLocationSelection? = nil, typeCollection: ManifestCollection? = nil) {
        super.init(location: location, typeCollection: typeCollection)

        evaluator.registerKey(.locationType) { [weak self] () -> (Bool) in
            return (self?.isValid).isTrue
        }
    }

    // MARK: - EvaluationObserverable
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {}
}


/// Delegate for generic location selection view model
public protocol OldLocationSelectionMapViewModelDelegate: class {

    /// Called when the selection is completed
    func didCompleteWithLocation(_ location: OldLocationSelection?)
}

/// View model for generic location selection
open class OldLocationSelectionMapViewModel {

    // MARK: - PUBLIC

    /// Delegate for location changes
    public weak var delegate: OldLocationSelectionMapViewModelDelegate?

    /// The currently selected location
    public var location: OldLocationSelection?

    /// Whether to drop pin and reverse geolocate location when first showing screen
    public var dropsPinAutomatically: Bool = false

    /// The manifest collection to use for location type options
    public var locationTypeManifestCollection: ManifestCollection?

    /// The selected location type
    public var locationType: PickableManifestEntry?

    /// The available location types
    open var locationTypeOptions: [PickableManifestEntry] {
        guard let collection = locationTypeManifestCollection else { return [] }
        return Manifest.shared.entries(for: collection)?.pickableList() ?? []
    }

    /// Whether the current selection is valid
    open var isValid: Bool {
        return location != nil && (locationTypeOptions.isEmpty || locationType != nil)
    }

    // Text to use in form
    public var navTitle: String? = NSLocalizedString("Select Location", comment: "")
    public var headerTitle: String? = NSLocalizedString("Location Details", comment: "")
    public var locationTypeTitle: String? = NSLocalizedString("Type", comment: "")
    public var addressTitle: String? = NSLocalizedString("Address", comment: "")

    /// Init
    public init(location: OldLocationSelection? = nil, typeCollection: ManifestCollection? = nil) {
        self.location = location
        self.locationTypeManifestCollection = typeCollection
        self.locationType = locationTypeOptions.first
    }

    /// Reverse geocode the given coordinates to get a placemark address string
    open func reverseGeocode(from coords: CLLocationCoordinate2D) -> Promise<Void> {
        guard self.location?.addressString == nil else { return Promise() }

        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        return LocationManager.shared.requestPlacemark(from: location).done { [weak self] (placemark) -> Void in
            self?.location = OldLocationSelection(placemark: placemark)
            }.recover { _ in
                // Ignore errors looking up address
        }
    }

    /// Complete the selection with the current location
    open func completeWithSelection() {
        delegate?.didCompleteWithLocation(location)
    }

}
