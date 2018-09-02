//
//  ManifestSetting.swift
//  CleintKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

public extension Settings {

    /// Setting for manifest handling
    ///
    /// Fully updates the manifest
    public static var manifest = Setting(title: "Update Manifest",
                                         subtitle: Settings.formattedManifestString(),
                                         image: nil,
                                         type: .button(action: updateManifest),
                                         onLoad: updateSettingSubtitle)

    private static func updateManifest(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {
        let loadingBuilder = LoadingViewBuilder<Void>()
        loadingBuilder.title = "Downloading manifest"
        loadingBuilder.request = {
            return Manifest.shared.fetchManifest(collections: nil, sinceDate: nil).done {
                updateSettingSubtitle()
                completion?()
            }
        }

        LoadingViewController.presentWith(loadingBuilder, from: viewController)
    }

    private static func updateSettingSubtitle() {
        self.manifest.subtitle = Settings.formattedManifestString()
    }

    private static func formattedManifestString() -> String {
        return "Updated \(Manifest.shared.lastUpdateDate?.elapsedTimeIntervalForHuman() ?? "never")"
    }
}
