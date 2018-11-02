//
//  AppDelegate+DataMigration.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

extension AppDelegate {

    /// Register CodableWrapper types for serialising entities
    func registerCodableWrapperTypes() {
        CodableWrapper.register(Person.self)
        CodableWrapper.register(Vehicle.self)
        CodableWrapper.register(Organisation.self)
        CodableWrapper.register(Address.self)
    }

}
