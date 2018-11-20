//
//  LocationInfoViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import PublicSafetyKit

open class LocationInfoViewModel: EntityDetailFormViewModel {

    private var location: Address? {
        return entity as? Address
    }

    private var travelTimeETA: String?
    private var travelTimeDistance: String?

    public var travelEstimationPlugin: TravelEstimationPlugable = TravelEstimationPlugin()

    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title

        guard let location = location else {
            return
        }

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: ""), separatorColor: .clear)

        var travelAccessory: CustomItemAccessory?

        let asset = AssetManager.shared.image(forKey: .entityCarSmall)

        if let travelTime = travelTimeETA,
            let travelDistance = travelTimeDistance {
            let travelTimeAccessoryView = TravelTimeAccessoryView(image: asset, distance: travelDistance, time: travelTime, frame: CGRect(x: 0, y: 0, width: 100, height: 30))

            travelAccessory = CustomItemAccessory(onCreate: { () -> UIView in
                return travelTimeAccessoryView
            }, size: CGSize(width: 100, height: 30))

        }

        let addressFormItem = AddressFormItem()
            .styleIdentifier(PublicSafetyKitStyler.addressLinkStyle)
            .title(StringSizing(string: "Address"))
            .subtitle(StringSizing(string: location.fullAddress, font: UIFont.preferredFont(forTextStyle: .subheadline)))
            .selectionAction(AddressNavigationSelectionAction(addressNavigatable: location))
            .width(.column(1))
            .accessory(travelAccessory)
        builder += addressFormItem

        let coordItem = ValueFormItem()
            .title(StringSizing(string: "Latitude, Longitude", font: UIFont.preferredFont(forTextStyle: .subheadline)))
            .value(StringSizing(string: location.coordinateStringRepresentation(), font: UIFont.preferredFont(forTextStyle: .subheadline)))
            .width(.column(1))
        builder += coordItem
    }

    open override var title: String? {
        return NSLocalizedString("Information", comment: "")
    }

    open override var noContentTitle: String? {
        return NSLocalizedString("No Location Found", comment: "")
    }

    open override var noContentSubtitle: String? {
        return NSLocalizedString("There are no details for this location", comment: "")
    }

    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .infoFilled)
    }

    open override func didSetEntity() {
        super.didSetEntity()
        LocationManager.shared.requestLocation().then(calculateETAandDistance).done { [weak self] in
            self?.delegate?.reloadData()
        }.cauterize()
    }

    // MARK: - Private

    private func suitableForHabitationText(for address: Address) -> String {
        // Data is not available yet.
        return "-"
    }

    private func location(from address: Address?) -> CLLocation? {
        guard let lat = address?.latitude,
            let long = address?.longitude else { return nil }

        return CLLocation(latitude: lat, longitude: long)
    }

    private func calculateETAandDistance(currentLocation: CLLocation) -> Promise<Void> {
        guard let location = location(from: location) else { return Promise<Void>() }
        let promises: [Promise<Void>] = [
            travelEstimationPlugin.calculateDistance(from: currentLocation, to: location).done {
                self.travelTimeDistance = $0
            },
            travelEstimationPlugin.calculateETA(from: currentLocation, to: location, transportType: .automobile).done {
                self.travelTimeETA = $0
            }
        ]
        return when(fulfilled: promises).asVoid()
    }

}

extension LocationInfoViewModel: EntityLocationMapDisplayable {

    public func mapSummaryDisplayable() -> EntityMapSummaryDisplayable? {
        guard let location = location else {
            return nil
        }
        return AddressSummaryDisplayable(location)
    }

}
