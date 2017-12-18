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
    public var equipment: [QuantityPicked]?
    public var remarks: String?
    public var startTime: Date?
    public var endTime: Date?
    public var duration: String?
    public var officers: [Officer] = []
    
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
        
        public init(withModel officer: OfficerDetailsResponse) {
            self.title = officer.displayName
            self.rank = officer.rank
            self.officerId = officer.payrollId
            self.licenseType = officer.licenceTypeId

            // Rest of properties are not loaded from backend, user has to enter
        }

        public static func ==(lhs: Officer, rhs: Officer) -> Bool {
            guard lhs.officerId != nil && rhs.officerId != nil else { return false }
            
            return lhs.officerId == rhs.officerId
        }
    }
}

