//
//  OrganisationEditContactFormViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

/// View Model for detail creation form
public class OrganisationEditContactFormViewModel {

    // MARK: PUBLIC

    /// current selected type of the detail type
    public var selectedType: Contact.ContactType?

    public var contact: Contact?

    public init(contact: Contact?) {
        self.contact = contact
        self.selectedType = contact?.type
    }
}
