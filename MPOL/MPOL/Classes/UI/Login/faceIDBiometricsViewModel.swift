//
//  faceIDBiometricsViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class faceIDBiometricsViewModel: BiometricsViewModelable {

    public var image: UIImage? {
        return UIImage(named: "faceID")
    }

    public var title: StringSizable? {
        return "Face ID Log In"
    }

    public var description: StringSizable? {
        return "Use your Face ID to log into the app in the future. This setting can be enabled/ disabled from within the Settings menu."
    }

    public var warning: StringSizable? {
        return nil
    }

    public var enableText: String? {
        return "Enable Face ID"
    }

    public var dontEnableText: String? {
        return "Not Now"
    }

    public var enableHandler: ()->()
    public var dontEnableHandler: ()->()

    init(enableHandler: @escaping ()->(), dontEnableHandler: @escaping ()->()) {
        self.enableHandler = enableHandler
        self.dontEnableHandler = dontEnableHandler
    }
}
