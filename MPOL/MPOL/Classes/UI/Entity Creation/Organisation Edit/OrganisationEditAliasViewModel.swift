//
//  OrganisationEditAliasViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

/// View Model for detail creation form
public class OrganisationEditAliasFormViewModel {

    // MARK: PUBLIC

    /// current selected type of the detail type
    public var selectedType: AnyPickable?

    public var organisationAlias: OrganisationAlias?

    public static let aliasOptions = Manifest.shared.entries(for: .organisationNameType)!.map { AnyPickable($0.rawValue!) }

    public init(organisationAlias: OrganisationAlias?) {
        self.organisationAlias = organisationAlias
        self.selectedType = organisationAlias?.type != nil ? AnyPickable(organisationAlias!.type!) : nil
    }
}
