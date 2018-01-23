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
    open var initials: String?

    // MARK: - Derived properties

    open var isDriver: Bool?

    open var subtitle: String {
        if inComplete {
            return NSLocalizedString("Additional details required", comment: "")
        }
        return [rank, officerId, licenceTypeId].joined(separator: ThemeConstants.dividerSeparator)
    }

    open var driverStatus: String? {
        if isDriver.isTrue {
            return NSLocalizedString("D", comment: "Driver abbreviation")
        }
        return nil
    }

    open var inComplete: Bool {
        return licenceTypeId?.ifNotEmpty() == nil
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
        self.initials = officer.initials
    }

    /// Create view model from model
    public init(withModel officer: SyncDetailsOfficer, initial: Bool, isDriver: Bool = false) {
        self.title = officer.displayName
        self.rank = officer.rank
        self.officerId = officer.payrollId
        self.isDriver = isDriver
        self.initials = officer.initials

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
    
    public func thumbnail() -> UIImage? {
        guard let initials = initials else { return nil}
        return UIImage.thumbnail(withInitials: initials).withCircleBackground(tintColor: nil,
                                                                              circleColor: .disabledGray,
                                                                              style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                            padding: CGSize(width: 14, height: 14))
        )
    }

}
