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

        let asset = AssetManager.shared.image(forKey: .entityCarSmall)

        // Only create travel Accessory if we have the data to fill it
        var travelAccessory: CustomItemAccessory?

        if let travelTime = travelTimeETA, let travelDistance = travelTimeDistance {
            let travelTimeAccessoryView = TravelTimeAccessoryView(image: asset, distance: travelDistance, time: travelTime, frame: CGRect(x: 0, y: 0, width: 120, height: 30))

            travelAccessory = CustomItemAccessory(onCreate: { () -> UIView in
                return travelTimeAccessoryView
            }, size: CGSize(width: 100, height: 30))

        }

        var linkAttributes = [NSAttributedStringKey : Any]()

        if let tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint) {
            linkAttributes[NSAttributedStringKey.foregroundColor] = tintColor
        }

        builder += ValueFormItem()
            .title(NSAttributedString(string: "Address"))
            .value(NSAttributedString(string: addressText(for: location), attributes: linkAttributes))
            .width(.column(1))
            .accessory(travelAccessory)
            .onSelection { cell in
                let handler = AddressOptionHandler(coordinate: CLLocation(latitude: location.latitude!, longitude: location.longitude!).coordinate, address: location.fullAddress)
                viewController.presentActionSheetPopover(handler.actionSheetViewController(), sourceView: cell, sourceRect: cell.bounds, animated: true)
        }

        builder += ValueFormItem()
            .title(NSAttributedString(string: "Latitude, Longitude"))
            .value(NSAttributedString(string: coordinateText(for: location)))
            .width(.column(1))
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

    override func didSetEntity() {
        super.didSetEntity()
        LocationManager.shared.requestLocation().done(calculateETAandDistanceFromCurrentLocation).cauterize()
    }

    // MARK - Private

    func addressText(for address: Address) -> String {
    
        if let text = address.fullAddress {
            return text
        }

        if let text = AddressFormatter().formattedString(from: address) {
            return text
        }

        return "-"
    }

    func coordinateText(for address: Address) -> String {
        guard let latitude = address.latitude, let longitude = address.longitude else {
            return "-"
        }

        return "\(latitude), \(longitude)"
    }

    func suitableForHabitationText(for address: Address) -> String {
        // Data is not available yet.
        return "-"
    }

    private func calculateETAandDistanceFromCurrentLocation(_ currentLocation: CLLocation) {
        guard let location = location else { return }
        calculateETAandDistance(currentLocation: currentLocation, address: location).done {
            self.delegate?.reloadData()
            }.cauterize()
    }

    private func calculateETAandDistance(currentLocation: CLLocation, address: Address) -> Promise<Void> {
        guard let location = location(from: self.location) else { return Promise<Void>() }
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

    private func location(from address: Address?) -> CLLocation? {
        guard let lat = address?.latitude,
            let long = address?.longitude else { return nil }

        return CLLocation(latitude: lat, longitude: long)
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
