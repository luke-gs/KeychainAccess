//
//  LocationInfoViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

open class LocationInfoViewModel: EntityDetailFormViewModel {

    private var location: Address? {
        return entity as? Address
    }

    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title

        guard let location = location else {
            return
        }

        builder += HeaderFormItem(text: NSLocalizedString("DETAILS", comment: ""), style: .collapsible)

        builder += ValueFormItem(title: NSLocalizedString("Address", comment: ""), value: addressText(for: location))
            .width(.column(1)).highlightStyle(.fade)
        builder += ValueFormItem(title: NSLocalizedString("Latitude, Longitude", comment: ""), value: coordinateText(for: location))
            .width(.column(2))
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
}

extension LocationInfoViewModel: EntityLocationMapDisplayable {

    public func mapSummaryDisplayable() -> EntityMapSummaryDisplayable? {
        guard let location = location else {
            return nil
        }
        return AddressSummaryDisplayable(location)
    }

}
