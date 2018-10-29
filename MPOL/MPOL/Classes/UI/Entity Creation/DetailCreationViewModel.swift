//
//  DetailCreationViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public enum DetailCreationType {
    case Contact(DetailCreationContactType)
    case Alias(DetailCreationAliasType)
    case Address
}

/// View Model for detail creation form
public class DetailCreationViewModel {

    // MARK: PUBLIC

    /// detail type of the form
    public var detailType: DetailCreationType

    /// current selected type of the detail type
    public var selectedType: String?

    public init(type: DetailCreationType) {
        detailType = type
    }
}

// MARK: Contact

// TODO: need to support loading from Manefest
public enum DetailCreationContactType: String {
    case Empty
    case Number
    case Mobile
    case Email
}

public extension DetailCreationContactType {

    /// Returns all contact types in strings except Empty
    /// - Returns: strings of contact types
    public static func allCase() -> [String] {
        return [DetailCreationContactType.Number.rawValue,
                DetailCreationContactType.Mobile.rawValue,
                DetailCreationContactType.Email.rawValue]
    }
}

// MARK: Alias

public enum DetailCreationAliasType: String {
    case Empty
    case Maiden = "Maiden Name"
    case PreferredName = "Preferred Name"
    case Nickname
    case Others
}

public extension DetailCreationAliasType {
    public static func allCase() -> [String] {
        if let items = Manifest.shared.entries(for: .personAliasType)?.rawValues() {
            return items
        }
        return []
    }
}


// MARK: Address
