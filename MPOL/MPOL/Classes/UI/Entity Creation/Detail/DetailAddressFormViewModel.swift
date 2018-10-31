//
//  DetailAddressFormViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

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

/// View Model for detail creation form
public class DetailAddressFormViewModel {

    // MARK: PUBLIC

    /// detail type of the form
    public var detailType: DetailCreationAddressType

    /// current selected type of the detail type
    public var selectedType: String?
    /// The location of the addresses
    public var selectedLocation: LocationSelectionType?
    public var locationRemark: String?

    public weak var delegate: DetailCreationDelegate?

    public init(type: DetailCreationAddressType, delegate: DetailCreationDelegate? = nil) {
        self.detailType = type
        self.delegate = delegate
    }
}
