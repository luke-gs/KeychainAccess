//
//  ThemeManager+HTML.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

extension ThemeManager {

    /// Links to the stylesheets according to UserInterfaceStyle
    public static var htmlStyleMap: [UserInterfaceStyle: URL] = {
        let lightURL = Bundle.main.url(forResource: "LightModeStyle", withExtension: "css")!
        let darkURL = Bundle.main.url(forResource: "DarkModeStyle", withExtension: "css")!
        return [.light: lightURL, .dark: darkURL]
    }()

}
