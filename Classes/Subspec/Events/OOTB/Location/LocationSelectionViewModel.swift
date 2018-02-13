//
//  LocationSelectionViewModel.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class LocationSelectionViewModel {
    var location: CLPlacemark?

    public init() { }

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
}
