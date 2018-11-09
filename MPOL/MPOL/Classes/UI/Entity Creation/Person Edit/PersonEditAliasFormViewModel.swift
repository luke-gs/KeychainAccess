//
//  PersonEditAliasFormViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// View Model for detail creation form
public class PersonEditAliasFormViewModel {

    // MARK: PUBLIC

    /// current selected type of the detail type
    public var selectedType: AnyPickable?

    public var personAlias: PersonAlias?

    public static let aliasOptions = Manifest.shared.entries(for: .personAliasType)!.map { AnyPickable($0.rawValue!) }

    public init(personAlias: PersonAlias?) {
        self.personAlias = personAlias
        self.selectedType = personAlias?.type != nil ? AnyPickable(personAlias!.type!) : nil
    }
}
