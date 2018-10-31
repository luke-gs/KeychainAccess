//
//  DetailAliasFormViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

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

/// View Model for detail creation form
public class DetailAliasFormViewModel {

    // MARK: PUBLIC

    /// detail type of the form
    public var detailType: DetailCreationAliasType

    /// current selected type of the detail type
    public var selectedType: String?

    public var personAlias: PersonAlias?

    public init(type: DetailCreationAliasType = .empty) {
        self.detailType = type
    }
}
