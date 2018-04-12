//
//  BookOnDetailsFormContentMainViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 26/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Book on details form view model, representing the underlying data for a CADBookOnDetailsType
open class BookOnDetailsFormContentMainViewModel {

    public init() {}

    // MARK: - Stored properties

    open var serial: String?
    open var category: String?
    open var odometer: String?
    open var remarks: String?
    open var startTime: Date?
    open var endTime: Date?
    open var duration: String?
    open var equipment: [QuantityPicked] = []
    open var officers: [BookOnDetailsFormContentOfficerViewModel] = []

    // MARK: - Conversion

    /// Create view model from model
    public init(withModel request: CADBookOnDetailsType) {
        self.serial = request.serial
        self.category = request.category
        self.odometer = request.odometer
        self.remarks = request.remarks
        self.startTime = request.shiftStart
        self.endTime = request.shiftEnd
        self.equipment = request.equipment.quantityPicked()

        // Create the officers, setting is driver based on driverpayrollId
        self.officers = request.officers.map { officer in
            let isDriver = officer.payrollId == request.driverpayrollId
            return BookOnDetailsFormContentOfficerViewModel(
                withModel: officer, initial: false, isDriver: isDriver)
        }
    }

    public init(withResource resource: CADResourceType) {
        self.serial = resource.serial
        self.category = resource.category
        self.odometer = resource.odometer
        self.remarks = resource.remarks
        self.startTime = resource.shiftStart
        self.endTime = resource.shiftEnd
        self.equipment = resource.equipment.quantityPicked()

        // Create the officers, setting is driver based on resource driver
        self.officers = resource.payrollIds.compactMap { payrollId in
            let isDriver = payrollId == resource.driver
            if let officer = CADStateManager.shared.officersById[payrollId] {
                return BookOnDetailsFormContentOfficerViewModel(
                    withModel: officer, initial: false, isDriver: isDriver)
            }
            return nil
        }
    }

    /// Create model from view model
    open func createModel() -> CADBookOnDetailsType {
        let request = CADClientModelTypes.bookonDetails.init()
        request.serial = self.serial
        request.category = self.category
        request.odometer = self.odometer
        request.remarks = self.remarks
        request.shiftStart = self.startTime
        request.shiftEnd = self.endTime
        request.driverpayrollId = self.officers.first { $0.isDriver.isTrue }?.officerId

        // Use the officer view models to apply changes to officers fetched in sync
        request.officers = self.officers.compactMap { officer in
            if let existingOfficer = CADStateManager.shared.officersById[officer.officerId!] {
                let updatedOfficer = CADClientModelTypes.officerDetails.init(officer: existingOfficer)
                updatedOfficer.licenceTypeId = officer.licenceTypeId
                updatedOfficer.contactNumber = officer.contactNumber
                updatedOfficer.capabilities = officer.capabilities
                updatedOfficer.remarks = officer.remarks
                return updatedOfficer
            }
            return nil
        }

        // Return only selected equipment
        request.equipment = self.equipment.compactMap { item in
            if let title = item.object.title, item.count > 0 {
                return CADClientModelTypes.equipmentDetails.init(count: item.count, description: title)
            }
            return nil
        }
        return request
    }
}

/// Extension for arrays of equipment items
extension Array where Element == CADEquipmentType {

    public func quantityPicked() -> [QuantityPicked] {
        let equipmentItemsByTitle = CADStateManager.shared.equipmentItemsByTitle()
        return self.compactMap { item in
            if let pickable = equipmentItemsByTitle[item.description] {
                return QuantityPicked(object: pickable, count: item.count)
            }
            return nil
        }
    }
}

