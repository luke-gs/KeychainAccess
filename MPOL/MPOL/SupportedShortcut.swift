//
//  SupportedShortcut.swift
//  MPOL
//
//  Created by Herli Halim on 9/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

enum SupportedShortcut: String {
    case searchPerson
    case searchVehicle
    case launchTasks

    init?(type: String) {

        guard let last = type.components(separatedBy: ".").last else {
            return nil
        }

        self.init(rawValue: last)
    }

    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
}
