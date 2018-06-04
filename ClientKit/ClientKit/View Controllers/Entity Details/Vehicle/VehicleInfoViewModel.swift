//
//  VehicleInfoViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

open class VehicleInfoViewModel: EntityDetailFormViewModel {

    public let showsRegistrationDetails: Bool

    public init(showsRegistrationDetails: Bool) {
        self.showsRegistrationDetails = showsRegistrationDetails
    }

    private var vehicle: Vehicle? {
        return entity as? Vehicle
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        
        guard let vehicle = vehicle else { return }
        
        // ---------- HEADER ----------
        
        let displayable = VehicleDetailsDisplayable(vehicle)
        
        builder += HeaderFormItem(text: header(for: .header), style: .collapsible)
        let thumbnailSize: EntityThumbnailView.ThumbnailSize = displaysCompact(in: viewController) ? .medium : .large
        builder += SummaryDetailFormItem()
            .category(displayable.category)
            .title(displayable.title)
            .subtitle(displayable.detail1)
            .borderColor(displayable.borderColor)
            .imageTintColor(displayable.iconColor)
            .image(displayable.thumbnail(ofSize: thumbnailSize))

        // ---------- VEHICLE DETAILS ----------
        builder += HeaderFormItem(text: header(for: .vehicleDetails), style: .collapsible)

        builder += ValueFormItem(title: NSLocalizedString("Year of Manufacture", bundle: .mpolKit, comment: ""), value: vehicle.year ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Make", bundle: .mpolKit, comment: ""), value: vehicle.make ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Model", bundle: .mpolKit, comment: ""), value: vehicle.model ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("VIN", bundle: .mpolKit, comment: ""), value: vehicle.vin ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Chassis Number", bundle: .mpolKit, comment: ""), value: vehicle.chassisNumber ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Engine Number", bundle: .mpolKit, comment: ""), value: vehicle.engineNumber ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Transmission", bundle: .mpolKit, comment: ""), value: vehicle.transmission ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Primary Colour", bundle: .mpolKit, comment: ""), value: vehicle.primaryColor ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Secondary Colour", bundle: .mpolKit, comment: ""), value: vehicle.secondaryColor ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Seating Capacity", bundle: .mpolKit, comment: ""), value: {
            guard let seatCapacity = vehicle.seatingCapacity, seatCapacity > 0 else { return "-" }
            return String(describing: seatCapacity)
        }())
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("TARE", bundle: .mpolKit, comment: ""), value: "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Gross Vehicle Mass", bundle: .mpolKit, comment: ""), value: {
            guard let weight = vehicle.weight, weight > 0 else { return "-" }
            return "\(weight) kg"
        }())
            .width(.column(3))

        // ---------- REGISTRATION DETAILS ----------
        if showsRegistrationDetails {

            builder += HeaderFormItem(text: header(for: .registrationDetails), style: .collapsible)
            builder += ValueFormItem(title: NSLocalizedString("State", comment: ""), value: vehicle.registrationState ?? "-")
                .width(.column(3))
            builder += ValueFormItem(title: NSLocalizedString("Status", comment: ""), value: vehicle.registrationStatus ?? "-")
                .width(.column(3))
            builder += ValueFormItem(title: NSLocalizedString("Valid until", comment: ""))
                .value({
                    if let date = vehicle.registrationExpiryDate {
                        return DateFormatter.preferredDateStyle.string(from: date)
                    }
                    return "-"
                }())
                .width(.column(3))


            let address = vehicle.addresses?.first
            let addressText = address?.fullAddress ?? "-"
            builder += ValueFormItem(title: NSLocalizedString("Address", comment: ""), value: addressText)
                .width(.column(1))
            
            // TODO: - Implement a proper way to present / delegate the presentation of options.
            /*
            let attributedValue = NSAttributedString(string: addressText, attributes: [ .foregroundColor : UIColor.brightBlue ])
            builder += ValueFormItem(title: NSLocalizedString("Address", comment: ""), value: attributedValue)
                .width(.column(1))
             */
        }

    }
    
    open override var title: String? {
        return NSLocalizedString("Information", bundle: .mpolKit, comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Vehicle Found", bundle: .mpolKit, comment: "")
    }
    
    open override var noContentSubtitle: String? {
        return NSLocalizedString("There are no details for this vehicle", bundle: .mpolKit, comment: "")
    }
    
    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .info)
    }
    
    // MARK: - Internal
    
    private enum Section {
        case header
        case vehicleDetails
        case registrationDetails
    }
    
    private func header(for section: Section) -> String? {
        switch section {
        case .header:
            let lastUpdated: String
            if let date = vehicle?.lastUpdated {
                lastUpdated = DateFormatter.preferredDateStyle.string(from: date)
            } else {
                lastUpdated = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
            }
            return String(format: NSLocalizedString("LAST UPDATED: %@", bundle: .mpolKit, comment: ""), lastUpdated)
        case .vehicleDetails:
            return NSLocalizedString("VEHICLE DETAILS", comment: "")
        case .registrationDetails:
            return NSLocalizedString("REGISTRATION DETAILS", comment: "")
        }
    }

    open override func traitCollectionDidChange(_ traitCollection: UITraitCollection, previousTraitCollection: UITraitCollection?) {
        delegate?.reloadData()
    }

    private func displaysCompact(in controller: FormBuilderViewController) -> Bool {
        let formLayout = controller.formLayout!
        let collectionView = controller.collectionView
        let itemInsets = formLayout.itemLayoutMargins
        let horizontalInsets = UIEdgeInsets(top: 0,
                                            left: collectionView?.layoutMargins.left ?? 0,
                                            bottom: 0,
                                            right: collectionView?.layoutMargins.right ?? 0)
        let calculatedWidth = formLayout.collectionViewContentSize.width - itemInsets.left - itemInsets.right - horizontalInsets.left - horizontalInsets.right

        return EntityDetailCollectionViewCell.displaysAsCompact(withContentWidth: calculatedWidth)
    }
}
