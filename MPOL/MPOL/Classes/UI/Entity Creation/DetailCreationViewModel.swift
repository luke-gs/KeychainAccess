//
//  DetailCreationViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// Type of form
///
/// - contact: contact form
/// - alias: alias form
/// - address: address form
public enum DetailCreationType {
    case contact(DetailCreationContactType)
    case alias(DetailCreationAliasType)
    case address(DetailCreationAddressType)
}

/// View Model for detail creation form
public class DetailCreationViewModel {

    // MARK: PUBLIC

    /// detail type of the form
    public var detailType: DetailCreationType

    /// current selected type of the detail type
    public var selectedType: String?
    /// The location of the addresses
    public var selectedLocation: LocationSelectionType?
    public var locationRemark: String?

    public var contact: Contact?

    public var personAlias: PersonAlias?

    public weak var delegate: DetailCreationDelegate?

    public init(type: DetailCreationType, delegate: DetailCreationDelegate? = nil) {
        self.detailType = type
        self.delegate = delegate
    }
}

public protocol DetailCreationDelegate: class {
    func onComplete(contact: Contact)
    func onComplete(alias: PersonAlias)
    func onComplete(type: DetailCreationAddressType ,location: LocationSelectionType, remark: String?)
}

// MARK: Contact

public enum DetailCreationContactType: String {
    case empty
    case number = "Number"
    case mobile = "Mobile Number"
    case email = "Email"
}

public extension DetailCreationContactType {

    /// Returns all contact types in strings except Empty
    /// - Returns: strings of contact types
    public static var allCase: [String] {
        return [DetailCreationContactType.number.rawValue,
                DetailCreationContactType.mobile.rawValue,
                DetailCreationContactType.email.rawValue]
    }
}

// MARK: Alias

public enum DetailCreationAliasType: String {
    case empty
    case maiden = "Maiden Name"
    case preferredName = "Preferred Name"
    case nickname = "Nickname"
    case knownAs = "Known As"
    case formerName = "Former Name"
    case others = "Others"
}
// TODO: tightly coupled to manifest & hard-coded enum
public extension DetailCreationAliasType {
    /// Returns all alias types in strings from manifest
    /// - Returns: strings of alias types
    public static var allCase: [String] {
        if let items = Manifest.shared.entries(for: .personAliasType)?.rawValues() {
            return items
        }
        return []
    }
}

// MARK: Address

public enum DetailCreationAddressType: String {
    case empty
    case residential = "Residential Address"
    case work = "Work Address"
}

public extension DetailCreationAddressType {
    /// Returns addres types in strings except Empty
    /// - Returns: strings of address types
    public static var allCase: [String] {
        return [DetailCreationAddressType.residential.rawValue,
                DetailCreationAddressType.work.rawValue]
    }
}
