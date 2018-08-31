//
//  AppDelegate+Shortcuts.swift
//  MPOL
//
//  Created by Herli Halim on 9/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

extension AppDelegate {

    func installShortcuts(on application: UIApplication = UIApplication.shared) {

        let searchPersonShortcut = UIMutableApplicationShortcutItem(type: SupportedShortcut.searchPerson.type, localizedTitle: NSLocalizedString("ShortcutItem.SearchPersonTitle", comment: ""), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .search), userInfo: nil)

        let searchVehicleShortcut = UIMutableApplicationShortcutItem(type: SupportedShortcut.searchVehicle.type, localizedTitle: NSLocalizedString("ShortcutItem.SearchVehicleTitle", comment: ""), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .search), userInfo: nil)

        var shortcuts: [UIApplicationShortcutItem] = [ searchPersonShortcut, searchVehicleShortcut ]

        let url = URL(string: CAD_APP_SCHEME)!
        if application.canOpenURL(url) {
            let launchTaskShortcut = UIMutableApplicationShortcutItem(type: SupportedShortcut.launchTasks.type, localizedTitle: NSLocalizedString("ShortcutItem.LaunchTasks", comment: ""), localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .location), userInfo: nil)
            shortcuts.append(launchTaskShortcut)
        }

        application.shortcutItems = shortcuts
    }

    func removeShortcuts(from application: UIApplication = UIApplication.shared) {
        application.shortcutItems = nil
    }

}
