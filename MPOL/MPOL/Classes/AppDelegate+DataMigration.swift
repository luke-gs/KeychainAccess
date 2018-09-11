//
//  AppDelegate+DataMigration.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

extension AppDelegate {

    func performDataMigrationIfNecessary() {
        // Allow archived data stored using class modules that no longer exist to be loaded using current module
        NSKeyedUnarchiver.setClass(AssociationReason.self, forClassName: "ClientKit.AssociationReason")
        NSKeyedUnarchiver.setClass(Media.self, forClassName: "ClientKit.Media")
        NSKeyedUnarchiver.setClass(Officer.self, forClassName: "PS_Core.Officer")
    }
}

