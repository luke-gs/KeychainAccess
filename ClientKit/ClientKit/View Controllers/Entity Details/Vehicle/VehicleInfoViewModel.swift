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
    
    private var vehicle: Vehicle? {
        return entity as? Vehicle
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        
        guard let vehicle = vehicle else { return }
        
        // ---------- HEADER ----------
        
        let displayable = VehicleSummaryDisplayable(vehicle)
        
        builder += HeaderFormItem(text: header(for: .header), style: .collapsible)
        builder += SummaryDetailFormItem()
            .category(displayable.category)
            .title(displayable.title)
            .subtitle(displayable.detail1)
            .detail(vehicle.vehicleDescription ?? "No Description")
            .borderColor(displayable.borderColor)
            .image(displayable.thumbnail(ofSize: .large))
        
        // ---------- DETAILS ----------
        
        builder += HeaderFormItem(text: header(for: .details), style: .collapsible)
        builder += ValueFormItem(title: NSLocalizedString("Status", bundle: .mpolKit, comment: ""), value: vehicle.registrationStatus ?? "-")
            .width(.column(3))
        
        var progress: Float = 0
        if let date = vehicle.registrationExpiryDate {
            progress = Float((Date().timeIntervalSince1970 / date.timeIntervalSince1970))
        }
        
        builder += ProgressFormItem(title: NSLocalizedString("Valid until", bundle: .mpolKit, comment: ""))
            .value({
                if let date = vehicle.registrationExpiryDate {
                    return DateFormatter.preferredDateStyle.string(from: date)
                }
                return "-"
                }())
            .progress(progress)
            .progressTintColor(progress > 1.0 ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1))
            .isProgressHidden(vehicle.registrationExpiryDate == nil)
            .width(.column(2))
        
        builder += ValueFormItem(title: NSLocalizedString("Manufactured in", bundle: .mpolKit, comment: ""), value: vehicle.year ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Make", bundle: .mpolKit, comment: ""), value: vehicle.make ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Model", bundle: .mpolKit, comment: ""), value: vehicle.model ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("VIN/Chassis Number", bundle: .mpolKit, comment: ""), value: vehicle.vin ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Engine Number", bundle: .mpolKit, comment: ""), value: vehicle.engineNumber ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Fuel Type", bundle: .mpolKit, comment: ""), value: "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Transmission", bundle: .mpolKit, comment: ""), value: vehicle.transmission ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Primary Colour", bundle: .mpolKit, comment: ""), value: vehicle.primaryColor ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Secondary Colour", bundle: .mpolKit, comment: ""), value: vehicle.secondaryColor ?? "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Gross Vehicle Mass", bundle: .mpolKit, comment: ""), value: {
            guard let weight = vehicle.weight, weight > 0 else { return "-" }
            return "\(weight) kg"
        }())
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("TARE", bundle: .mpolKit, comment: ""), value: "-")
            .width(.column(3))
        builder += ValueFormItem(title: NSLocalizedString("Seating Capacity", bundle: .mpolKit, comment: ""), value: {
            guard let seatCapacity = vehicle.seatingCapacity, seatCapacity > 0 else { return "-" }
            return String(describing: seatCapacity)
        }()).width(.column(3))
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
        case details
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
        case .details:
            return NSLocalizedString("REGISTRATION DETAILS", bundle: .mpolKit, comment: "")
        }
    }
}
