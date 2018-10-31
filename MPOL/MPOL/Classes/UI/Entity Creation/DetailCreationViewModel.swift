//
//  DetailCreationViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public protocol DetailCreationDelegate: class {
    func onComplete(contact: Contact)
    func onComplete(alias: PersonAlias)
    func onComplete(type: DetailCreationAddressType, location: LocationSelectionType, remark: String?)
}
