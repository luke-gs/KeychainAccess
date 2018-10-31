//
//  DetailAddressFormViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// View Model for detail creation form
public class DetailAddressFormViewModel {

    // MARK: PUBLIC

    /// current selected type of the detail type
    public var selectedType: AnyPickable?
    /// The location of the addresses
    public var selectedLocation: LocationSelectionType?
    public var locationRemark: String?

    public static let addressOptions = [NSLocalizedString("Residential Address", comment: ""),
                                        NSLocalizedString("Work Address", comment: "")].map { AnyPickable($0) }
}
