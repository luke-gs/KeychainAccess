//
//  DetailContactFormViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

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

/// View Model for detail creation form
public class DetailContactFormViewModel {

    // MARK: PUBLIC

    /// detail type of the form
    public var detailType: DetailCreationContactType

    /// current selected type of the detail type
    public var selectedType: String?

    public var contact: Contact?

    public weak var delegate: DetailCreationDelegate?

    public init(type: DetailCreationContactType, delegate: DetailCreationDelegate? = nil) {
        self.detailType = type
        self.delegate = delegate
    }
}
