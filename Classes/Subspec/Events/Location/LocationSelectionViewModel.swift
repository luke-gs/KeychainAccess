//
//  LocationSelectionViewModel.swift
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

public protocol LocationSelectionViewModelDelegate: class {
    func didSelect(location: EventLocation?)
}

open class LocationSelectionViewModel: Evaluatable {

    public var evaluator: Evaluator = Evaluator()
    public weak var delegate: LocationSelectionViewModelDelegate?
    private var placemark: CLPlacemark?

    public var dropsPinAutomatically: Bool = false

    public var location: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .locationType)
        }
    }
    public var type: PickableManifestEntry? {
        didSet {
            evaluator.updateEvaluation(for: .locationType)
        }
    }

    public var locationTypeOptions: [PickableManifestEntry] {
        return Manifest.shared.entries(for: .eventLocationInvolvementType)?.pickableList() ?? []
    }

    public init(location: EventLocation? = nil) {
        self.location = location
        evaluator.registerKey(.locationType) { () -> (Bool) in
            return self.location != nil && self.type != nil
        }
    }

    public func selectedValues() -> [PickableManifestEntry] {
        guard let type = type else { return [] }
        return [type]
    }

    public func reverseGeocode(from coords: CLLocationCoordinate2D) -> Promise<Void> {
        if location?.addressString != nil {
            return Promise()
        } else {
            let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
            let promise = LocationManager.shared.requestPlacemark(from: location).done { (placemark) -> Void in
                self.placemark = placemark
                self.composeLocation()
            }
            promise.catch { _ in }
            
            return promise
        }
    }

    public func completeLocationSelection() {
        delegate?.didSelect(location: location)
    }

    private func composeLocation() {
        guard let dictionary = placemark?.addressDictionary, let coords = placemark?.location?.coordinate else { return }
        guard let formattedAddress = dictionary["FormattedAddressLines"] as? [String] else { return }

        let fullAddress = formattedAddress.reduce("") { result, string  in
            return result + "\(string) "
        }

        location = EventLocation(location: coords, addressString: fullAddress)
    }

    // Eval

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
