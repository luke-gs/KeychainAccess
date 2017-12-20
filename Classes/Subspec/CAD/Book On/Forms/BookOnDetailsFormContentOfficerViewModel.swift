//
//  BookOnDetailsFormContentOfficerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Book on details officer form view model, representing the underlying data for a SyncDetailsOfficer
open class BookOnDetailsFormContentOfficerViewModel: Equatable {

    public init() {}

    // MARK: - Stored properties

    open var title: String?
    open var rank: String?
    open var officerId: String?
    open var licenceTypeId: String?
    open var contactNumber: String?
    open var capabilities: String?
    open var remarks: String?

    // MARK: - Derived properties

    open var isDriver: Bool?

    open var subtitle: String {
        return [rank, officerId, licenceTypeId].joined(separator: ThemeConstants.dividerSeparator)
    }

    open var driverStatus: String? {
        if isDriver.isTrue {
            return NSLocalizedString("DRIVER", comment: "").uppercased()
        }
        return nil
    }

    open var incompleteStatus: String? {
        if licenceTypeId == nil {
            return NSLocalizedString("Incomplete", comment: "").uppercased()
        }
        return nil
    }

    // MARK: - Conversion

    /// Create view model from existing view model
    public init(withOfficer officer: BookOnDetailsFormContentOfficerViewModel) {
        self.title = officer.title
        self.rank = officer.rank
        self.officerId = officer.officerId
        self.licenceTypeId = officer.licenceTypeId
        self.contactNumber = officer.contactNumber
        self.capabilities = officer.capabilities
        self.remarks = officer.remarks
        self.isDriver = officer.isDriver
    }

    /// Create view model from model
    public init(withModel officer: SyncDetailsOfficer, initial: Bool, isDriver: Bool = false) {
        self.title = officer.displayName
        self.rank = officer.rank
        self.officerId = officer.payrollId
        self.isDriver = isDriver

        if initial {
            // On initial add of officer, some properties user is forced to enter
        } else {
            self.licenceTypeId = officer.licenceTypeId
            self.contactNumber = officer.contactNumber
            self.capabilities = officer.capabilities
            self.remarks = officer.remarks
        }
    }

    open static func ==(lhs: BookOnDetailsFormContentOfficerViewModel, rhs: BookOnDetailsFormContentOfficerViewModel) -> Bool {
        return lhs.officerId == rhs.officerId
    }

}
