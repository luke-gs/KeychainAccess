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

    func performDataMigrationIfNecessary() {
        // Allow archived data stored using class modules that no longer exist to be loaded using current module
        NSKeyedUnarchiver.setClass(AssociationReason.self, forClassName: "ClientKit.AssociationReason")
        NSKeyedUnarchiver.setClass(Media.self, forClassName: "ClientKit.Media")
        NSKeyedUnarchiver.setClass(Officer.self, forClassName: "PS_Core.Officer")
    }

}
