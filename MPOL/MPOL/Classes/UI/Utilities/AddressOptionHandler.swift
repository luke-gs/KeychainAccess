//
//  AddressOptionHandler.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PatternKit
import PublicSafetyKit

/// Contains the reusuable logic around working with addresses
/// in particular allowing us to open to MKMaps or search for the address
public class AddressOptionHandler {

    public var addressString: String?
    public var coordinate: CLLocationCoordinate2D?

    private var defaultButtons: [ActionSheetButton] {
        return [
            openInAppleMapsButton(),
            openStreetViewButton(),
            searchAddressButton()
        ]
    }

    public init(coordinate: CLLocationCoordinate2D?, address: String?) {
        self.addressString = address
        self.coordinate = coordinate
    }

    /// Creates an ActionSheetViewController that presents the buttons given or the defaults if none are
    /// provided.
    open func actionSheetViewController(with buttons: [ActionSheetButton]? = nil) -> ActionSheetViewController {
        let buttons = buttons ?? defaultButtons
        return ActionSheetViewController(buttons: buttons)
    }

    open func openInAppleMapsButton() -> ActionSheetButton {
        return ActionSheetButton(title: "Directions", icon: AssetManager.shared.image(forKey: .route), action: {
            if let coordinate = self.coordinate {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
                mapItem.name = self.addressString
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } else if let address = self.addressString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: "http://maps.apple.com/?address=\(address)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                AlertQueue.shared.addErrorAlert(message: "No valid location data was found")
            }
        })
    }

    open func openStreetViewButton() -> ActionSheetButton {
        return ActionSheetButton(title: "Street View", icon: AssetManager.shared.image(forKey: .streetView), action: nil)
    }

    open func searchAddressButton() -> ActionSheetButton {
        return ActionSheetButton(title: "Search", icon: AssetManager.shared.image(forKey: .tabBarSearch), action: {
            let searchable = Searchable(text: self.addressString, type: LocationSearchDataSourceSearchableType)
            let activity = SearchActivity.searchEntity(parameters: SearchActivity.SearchEntityParameters(term: searchable))
            do {
                try SearchActivityLauncher.default.launch(activity, using: AppURLNavigator.default)
            } catch {
                AlertQueue.shared.addSimpleAlert(title: "An Error Has Occurred", message: "Failed To Launch Entity Search")
            }
        })
    }
}
