//
//  LocationSelectionMapViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit
import PromiseKit

/// Delegate for generic location selection view model
public protocol LocationSelectionMapViewModelDelegate: class {
    func didUpdateLocation(_ location: LocationSelection?)
}

/// View model for generic location selection
open class LocationSelectionMapViewModel {

    /// Delegate for location changes
    public weak var delegate: LocationSelectionMapViewModelDelegate?

    /// The currently selection location
    public var location: LocationSelection? {
        didSet {
            delegate?.didUpdateLocation(location)
        }
    }

    /// Convenience accessor for location coordinate
    public var coordinate: CLLocationCoordinate2D? {
        if let lat = location?.latitude, let lon = location?.longitude  {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    /// Whether to reverse geolocate initial location coordinates
    public var dropsPinAutomatically: Bool = false

    /// The manifest collection to use for location type options
    public var locationTypeManifestCollection: ManifestCollection?

    /// The selected location type
    public var locationType: PickableManifestEntry?

    /// The available location types
    public var locationTypeOptions: [PickableManifestEntry] {
        guard let collection = locationTypeManifestCollection else { return [] }
        return Manifest.shared.entries(for: collection)?.pickableList() ?? []
    }

    /// Whether the current selection is valid
    public var isValid: Bool {
        return location != nil && locationType != nil
    }

    // Text to use in form
    public var navTitle: String? = NSLocalizedString("Select Location", comment: "")
    public var headerTitle: String? = NSLocalizedString("Location Details", comment: "")
    public var locationTypeTitle: String? = NSLocalizedString("Type", comment: "")
    public var addressTitle: String? = NSLocalizedString("Address", comment: "")

    /// Constructor
    public init(location: LocationSelection? = nil, typeCollection: ManifestCollection? = nil) {
        self.location = location
        self.locationTypeManifestCollection = typeCollection
        self.locationType = locationTypeOptions.first
    }

    /// Reverse geocode the given coordinates to get a placemark address string
    open func reverseGeocode(from coords: CLLocationCoordinate2D) -> Promise<Void> {
        guard self.location?.addressString == nil else { return Promise() }

        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        return LocationManager.shared.requestPlacemark(from: location).done { [weak self] (placemark) -> Void in
            self?.updateLocation(from: placemark)
        }.recover { _ in
            // Ignore errors looking up address
        }
    }

    /// Update the current location with a given placemark
    open func updateLocation(from placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return }
        guard let formattedAddress = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else { return }
        let fullAddress = formattedAddress.joined(separator: " ")
        location = LocationSelection(coordinate: coordinate, addressString: fullAddress)
    }
}
