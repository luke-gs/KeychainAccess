//
//  BookOnDetailsFormContentViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 26/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Class for book on details, to be populated by form
public class BookOnDetailsFormContentViewModel {
    
    public var serial: String?
    public var category: String?
    public var odometer: String?
    public var remarks: String?
    public var startTime: Date?
    public var endTime: Date?
    public var duration: String?
    public var equipment: [QuantityPicked] = []
    public var officers: [Officer] = []

    public init() {
    }

    public init(withModel request: BookOnRequest) {
        self.serial = request.serial
        self.category = request.category
        self.odometer = request.odometer
        self.remarks = request.remarks
        self.startTime = request.shiftStart
        self.endTime = request.shiftEnd

        self.officers = request.officers.map { officer in
            let isDriver = officer.payrollId == request.driverpayrollId
            return Officer(withModel: officer, initial: false, isDriver: isDriver)
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

    public func createRequest() -> BookOnRequest {
        let request = BookOnRequest()
        request.serial = self.serial
        request.category = self.category
        request.odometer = self.odometer
        request.remarks = self.remarks
        request.shiftStart = self.startTime
        request.shiftEnd = self.endTime

        request.officers = self.officers.flatMap { officer in
            if let existingOfficer = CADStateManager.shared.officersById[officer.officerId!] {
                let updatedOfficer = SyncDetailsOfficer(officer: existingOfficer)
                updatedOfficer.licenceTypeId = officer.licenseType
                updatedOfficer.contactNumber = officer.contactNumber
                updatedOfficer.capabilities = officer.capabilities
                updatedOfficer.remarks = officer.remarks
                return updatedOfficer
            }
            return nil
        }
        request.equipment = self.equipment.flatMap { item in
            if item.count > 0 {
                return SyncDetailsResourceEquipment(count: item.count, description: item.object.title)
            }
            return nil
        }
        return request
    }

    public class Officer: Equatable {

        // From sync
        public var title: String?
        public var rank: String?
        public var officerId: String?
        public var licenseType: String?
        
        // From book on form
        public var contactNumber: String?
        public var capabilities: String?
        public var remarks: String?
        public var isDriver: Bool?
        
        public var subtitle: String {
            return [rank, officerId, licenseType].joined(separator: "  •  ")
        }

        public var driverStatus: String? {
            if let isDriver = isDriver, isDriver {
                return NSLocalizedString("DRIVER", comment: "").uppercased()
            }
            return nil
        }

        public var incompleteStatus: String? {
            if licenseType == nil {
                return NSLocalizedString("Incomplete", comment: "").uppercased()
            }
            return nil
        }
        
        public init() {}
        
        public init(withOfficer officer: Officer) {
            self.title = officer.title
            self.rank = officer.rank
            self.officerId = officer.officerId
            self.licenseType = officer.licenseType
            self.contactNumber = officer.contactNumber
            self.capabilities = officer.capabilities
            self.remarks = officer.remarks
            self.isDriver = officer.isDriver
        }
        
        public init(withModel officer: SyncDetailsOfficer, initial: Bool, isDriver: Bool = false) {
            self.title = officer.displayName
            self.rank = officer.rank
            self.officerId = officer.payrollId
            self.licenseType = officer.licenceTypeId
            self.isDriver = isDriver

            if initial {
                // On initial add of officer, some properties user has to enter
            } else {
                self.contactNumber = officer.contactNumber
                self.capabilities = officer.capabilities
                self.remarks = officer.remarks
            }
        }

        public static func ==(lhs: Officer, rhs: Officer) -> Bool {
            guard lhs.officerId != nil && rhs.officerId != nil else { return false }
            
            return lhs.officerId == rhs.officerId
        }
    }
}

