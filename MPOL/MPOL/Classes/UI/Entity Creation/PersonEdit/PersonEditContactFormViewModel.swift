//
//  PersonEditContactFormViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

/// View Model for detail creation form
public class PersonEditContactFormViewModel {

    // MARK: PUBLIC

    /// current selected type of the detail type
    public var selectedType: Contact.ContactType?

    public var contact: Contact?

    public init(contact: Contact?) {
        self.contact = contact
        self.selectedType = contact?.type
    }
}
