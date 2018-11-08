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

    private var addressConfig: AddressFormItemConfiguration?

    public var travelEstimationPlugin: TravelEstimationPlugable = TravelEstimationPlugin()

    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title

        guard let location = location else {
            return
        }

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: ""), separatorColor: .clear)

        if addressConfig == nil {
            addressConfig = AddressFormItemConfiguration(data: location, showTravelData: true)
            addressConfig!.delegate = self
        }

        let factory = AddressFormItemFactory(config: addressConfig!)
        builder += factory.defaultAddressFormItems( context: viewController)
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
}

extension LocationInfoViewModel: EntityLocationMapDisplayable {

    public func mapSummaryDisplayable() -> EntityMapSummaryDisplayable? {
        guard let location = location else {
            return nil
        }
        return AddressSummaryDisplayable(location)
    }

}

extension LocationInfoViewModel: AddressFormItemConfigurationDelegate {

    public func didFinishCalculatingEstimates(from: AddressFormItemConfiguration) {
        delegate?.reloadData()
    }

}
