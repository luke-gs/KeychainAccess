//
//  BookOnDetailsFormContentMainViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 26/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Book on details form view model, representing the underlying data for a BookOnRequest
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
    public init(withModel request: BookOnRequest) {
        self.serial = request.serial
        self.category = request.category
        self.odometer = request.odometer
        self.remarks = request.remarks
        self.startTime = request.shiftStart
        self.endTime = request.shiftEnd

        // Create the officers, setting is driver based on driverpayrollId
        self.officers = request.officers.map { officer in
            let isDriver = officer.payrollId == request.driverpayrollId
            return BookOnDetailsFormContentOfficerViewModel(
                withModel: officer, initial: false, isDriver: isDriver)
        }

        // Lookup equipment items from manifest
        let equipmentItemsByTitle = CADStateManager.shared.equipmentItemsByTitle()
        self.equipment = request.equipment.flatMap { item in
            if let pickable = equipmentItemsByTitle[item.description] {
                return QuantityPicked(object: pickable, count: item.count)
            }
            return nil
        }
    }

    /// Create model from view model
    open func createModel() -> BookOnRequest {
        let request = BookOnRequest()
        request.serial = self.serial
        request.category = self.category
        request.odometer = self.odometer
        request.remarks = self.remarks
        request.shiftStart = self.startTime
        request.shiftEnd = self.endTime
        request.driverpayrollId = self.officers.first { $0.isDriver.isTrue }?.officerId

        // Use the officer view models to apply changes to officers fetched in sync
        request.officers = self.officers.flatMap { officer in
            if let existingOfficer = CADStateManager.shared.officersById[officer.officerId!] {
                let updatedOfficer = SyncDetailsOfficer(officer: existingOfficer)
                updatedOfficer.licenceTypeId = officer.licenceTypeId
                updatedOfficer.contactNumber = officer.contactNumber
                updatedOfficer.capabilities = officer.capabilities
                updatedOfficer.remarks = officer.remarks
                return updatedOfficer
            }
            return nil
        }

        // Return only selected equipment
        request.equipment = self.equipment.flatMap { item in
            if item.count > 0 {
                return SyncDetailsResourceEquipment(count: item.count, description: item.object.title)
            }
            return nil
        }
        return request
    }
}

