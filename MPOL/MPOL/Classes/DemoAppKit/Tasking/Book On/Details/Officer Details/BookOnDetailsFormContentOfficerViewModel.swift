//
//  BookOnDetailsFormContentOfficerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 19/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PatternKit
import PublicSafetyKit
/// Book on details officer form view model, representing the underlying data for a CADOfficerType
open class BookOnDetailsFormContentOfficerViewModel: Equatable {

    public init(officerId: String) {
        self.officerId = officerId
    }

    // MARK: - Stored properties

    open var title: StringSizable?
    open var rank: String?
    open var officerId: String
    open var employeeNumber: String?
    open var licenceTypeId: String?
    open var contactNumber: String?
    open var radioId: String?
    open var capabilities: [String] = []
    open var remarks: String?
    open var initials: String?

    // MARK: - Derived properties

    open var isDriver: Bool?

    open var licenceTypeEntry: PickableManifestEntry? {
        if let licenceTypeId = licenceTypeId {
            if let entry = Manifest.shared.entry(withID: licenceTypeId) {
                return PickableManifestEntry(entry)
            }
        }
        return nil
    }

    open var subtitle: String {
        if inComplete {
            return NSLocalizedString("Additional details required", comment: "")
        }
        return officerInfoSubtitle
    }

    open var officerInfoSubtitle: String {
        return [rank, licenceTypeEntry?.entry.rawValue].joined(separator: ThemeConstants.dividerSeparator)
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
        self.employeeNumber = officer.employeeNumber
        self.licenceTypeId = officer.licenceTypeId
        self.contactNumber = officer.contactNumber
        self.capabilities = officer.capabilities
        self.remarks = officer.remarks
        self.isDriver = officer.isDriver
        self.initials = officer.initials
        self.radioId = officer.radioId
    }

    /// Create view model from model
    public init(withModel officer: CADOfficerType, initial: Bool, isDriver: Bool = false) {
        self.title = officer.displayName
        self.rank = officer.rank
        self.officerId = officer.id
        self.employeeNumber = officer.employeeNumber
        self.isDriver = isDriver
        self.initials = officer.initials
        self.radioId = officer.radioId

        if initial {
            // On initial add of officer, some properties user is forced to enter
        } else {
            self.licenceTypeId = officer.licenceTypeId
            self.contactNumber = officer.contactNumber
            self.capabilities = officer.capabilities
            self.remarks = officer.remarks
        }
    }

    public static func == (lhs: BookOnDetailsFormContentOfficerViewModel, rhs: BookOnDetailsFormContentOfficerViewModel) -> Bool {
        return lhs.officerId == rhs.officerId
    }

    public func thumbnail() -> UIImage? {
        var image: UIImage?
        var padding = CGSize(width: 14, height: 14)
        if let initials = initials?.ifNotEmpty() {
            image = UIImage.thumbnail(withInitials: initials)
        } else {
            image = AssetManager.shared.image(forKey: .entityPerson)
            padding = CGSize(width: 32, height: 32)
        }
        guard let thumbnail = image?.withCircleBackground(tintColor: nil,
                                                          circleColor: .disabledGray,
                                                          style: .fixed(size: CGSize(width: 48, height: 48),
                                                                        padding: padding)) else { return nil }
        return thumbnail
    }

}
