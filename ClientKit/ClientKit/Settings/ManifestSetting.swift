//
//  ManifestSetting.swift
//  CleintKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public extension Settings {

    /// Setting for manifest handling
    ///
    /// Fully updates the manifest
    public static let manifest = Setting(title: "Update Manifest",
                                         subtitle: Settings.formattedManifestString(),
                                         image: nil,
                                         type: .button(updateManifest))

    private static func updateManifest(_ viewController: UIViewController) {
        let loadingBuilder = LoadingViewBuilder<Void>()
        loadingBuilder.title = "Downloading manifest"
        loadingBuilder.request = {
            return Manifest.shared.fetchManifest()
        }

        LoadingViewController.presentWith(loadingBuilder, from: viewController)
    }

    private static func formattedManifestString() -> String {
        return "Updated \(Manifest.shared.lastUpdateDate?.elapsedTimeIntervalForHuman() ?? "never")"
    }
}
