//
//  LocationSelectionViewModel.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

public extension EvaluatorKey {
    static let locationType = EvaluatorKey(rawValue: "locationType")
}

public protocol LocationSelectionViewModelDelegate: class {
    func didSelect(location: EventLocation)
}

open class LocationSelectionViewModel: Evaluatable {

    public var evaluator: Evaluator = Evaluator()
    public weak var delegate: LocationSelectionViewModelDelegate?
    public var type: String? {
        didSet {
            evaluator.updateEvaluation(for: .locationType)
        }
    }
    public var location: CLPlacemark? {
        didSet {
            evaluator.updateEvaluation(for: .locationType)
        }
    }

    public init() {
        evaluator.registerKey(.locationType) { () -> (Bool) in
            return self.location != nil && self.type != nil
        }
    }

    public func reverseGeoCode(location: CLLocation?, completion: (()->())?) {
        guard let location = location else { return }
        LocationManager.shared.requestPlacemark(from: location).then { (placemark) -> Void in
            self.location = placemark
            completion?()
            }.catch { _ in }
    }

    public func composeAddress() -> String {
        guard let dictionary = location?.addressDictionary else { return "-" }
        guard let formattedAddress = dictionary["FormattedAddressLines"] as? [String] else { return "-" }

        let fullAddress = formattedAddress.reduce("") { result, string  in
            return result + "\(string) "
        }

        return fullAddress
    }

    public func completeLocationSelection() {
        guard let location = location?.location else { return }
        delegate?.didSelect(location: EventLocation(location: location, addressString: composeAddress()))
    }

    // Eval

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}
