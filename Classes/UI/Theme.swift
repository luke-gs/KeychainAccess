//
//  Theme.swift
//  MPOLKit
//
//  Created by Rod Brown on 15/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public extension NSNotification.Name {
    
    /// Posted when the current theme changes.
    public static let ThemeDidChange = NSNotification.Name(rawValue: "MPOL.ThemeDidChange")
}


/// The Theme state for MPOL and applications based on MPOLKit.
///
/// Applications can define their own theme pack by including a compliant "ThemePack.json"
/// file within their compiled bundle. Users who define their own theme should ensure they
/// include all the values for all MPOL base color keys, to ensure that MPOL views render
/// correctly according to the defined theme.
///
/// Apps that don't define a theme pack will inherit the default MPOL theme pack and appearances.
public class Theme: NSObject {
    
    private static let themePack: [[String: Any]] = {
        let themeFileURL: URL?
        
        if let themeURL = Bundle.main.url(forResource: "ThemePack", withExtension: "json") {
            if let themeArray = themeArray(at: themeURL) {
                bundle = .main
                return themeArray
            } else {
                NSLog("Application theme pack invalid.")
            }
        }
            
        if let themeURL = Bundle.mpolKit.url(forResource: "ThemePack", withExtension: "json") {
            if let themeArray = themeArray(at: themeURL) {
                bundle = .mpolKit
                return themeArray
            } else {
                NSLog("MPOLKit theme pack invalid.")
            }
        }
        return []
    }()
        
    private class func themeArray(at url: URL) -> [[String: Any]]? {
        if let data = try? Data(contentsOf: url),
            let jsonObject = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] {
            return jsonObject
        }
        return nil
    }
    
    private static var bundle: Bundle = .main
    
    private static var loadedThemes: [String: Theme] = [:]
    
    
    /// The current theme. By default, this is the first theme in the pack.
    public private(set) static var current: Theme = {
        guard let firstThemeItem = themePack.first(where: { ($0["name"] as? String)?.isEmpty ?? true == false }),
            let theme = Theme(details: firstThemeItem) else {
            fatalError(bundle == .mpolKit ? "No themes provided in MPOL." : "Theme pack in application is empty.")
        }
        
        loadedThemes[theme.name] = theme
        return theme
    }()
    
    
    /// All theme names in the current pack.
    ///
    /// The pack is loaded from a ThemePack.json file in your application. If you don't provide
    /// one, the theme pack falls back to the frameworks base pack.
    public static let allThemeNames: [String] = themePack.flatMap { $0["name"] as? String }
    
    
    /// Applies the specified theme.
    ///
    /// - Parameter name: The name of the theme. This name must be one of the themes in `Theme.allThemeNames`.
    /// - Returns: A boolean value indicating whether applying the theme succeeded. If it succeeded, a
    ///            `ThemeDidChange` notification is also posted.
    public class func applyTheme(withName name: String) -> Bool {
        
        if allThemeNames.contains(name) == false { return false } // We don't have this theme

        if Theme.current.name == name { return true } // It's the current one.
        
        let theme: Theme
        if let loadedTheme = loadedThemes[name] {
            theme = loadedTheme
        } else if let themeDictionary = themePack.first(where: { $0["name"] as? String == name }),
            let freshTheme = Theme(details: themeDictionary) {
            theme = freshTheme
            loadedThemes[name] = freshTheme
        } else {
            return false
        }
        
        Theme.current = theme
        NotificationCenter.default.post(name: .ThemeDidChange, object: theme)
        return true
    }
    
    /// The name of the theme.
    public let name: String
    
    /// A boolean value indicating if the theme is generally dark. Applications can use
    /// this value to toggle general appearances that are not specified directly on the theme.
    public let isDark: Bool
    
    /// The keyboard appearance appropriate for the theme.
    public let keyboardAppearance: UIKeyboardAppearance
    
    /// The status bar style appropriate for the assigned navigation bar style and color.
    public let statusBarStyle: UIStatusBarStyle
    
    /// The navigation bar background image.
    public let navigationBarBackgroundImage: UIImage?
    
    /// The navigation bar shadow image. This should be shared between the actual navigation
    /// bar, and any associated navigation bar background extensions
    public let navigationBarShadowImage: UIImage?
    
    /// The background image for an extension of the navigation bar
    public let navigationBarBackgroundExtensionImage: UIImage?
    
    /// The navigation bar style. When there is a background image set, this adjusts the
    /// title details etc.
    public let navigationBarStyle: UIBarStyle
    
    /// The tab bar style.
    public let tabBarStyle: UIBarStyle
    
    /// The colors for the theme.
    public let colors: [ThemeColorType: UIColor]
    
    internal init?(details: [String: Any]) {
        guard let name = details["name"] as? String else { return nil }
        
        self.name = name
        
        if let isDark = details["isDark"] as? Bool {
            self.isDark = isDark
            self.keyboardAppearance = isDark ? .dark : .light
        } else {
            self.isDark = false
            self.keyboardAppearance = .default
        }
        
        if let statusBarRawValue = details["statusBarStyle"] as? Int,
            let statusBarStyle = UIStatusBarStyle(rawValue: statusBarRawValue) {
            self.statusBarStyle = statusBarStyle
        } else {
            self.statusBarStyle = .default
        }
        
        var colors: [ThemeColorType: UIColor] = [:]
        (details["colors"] as? [String: String])?.forEach { (pair: (title: String, hex: String)) in
            if let color = UIColor(hexString: pair.hex) {
                colors[ThemeColorType(rawValue: pair.title)] = color
            }
        }
        self.colors = colors
        
        if let navBarName = details["navigationBar"] as? String {
            self.navigationBarBackgroundImage = UIImage(named: navBarName, in: Theme.bundle, compatibleWith: nil)
        } else {
            self.navigationBarBackgroundImage = nil
        }
        
        if let navBarExtensionName = details["navigationBarExtension"] as? String {
            self.navigationBarBackgroundExtensionImage = UIImage(named: navBarExtensionName, in: Theme.bundle, compatibleWith: nil)
        } else {
            self.navigationBarBackgroundExtensionImage = nil
        }
        
        if let navBarShadowName = details["navigationBarShadow"] as? String {
            self.navigationBarShadowImage = UIImage(named: navBarShadowName, in: Theme.bundle, compatibleWith: nil)
        } else {
            self.navigationBarShadowImage = nil
        }
        
        if let navBarStyleInt = details["navigationBarStyle"] as? Int,
            let navBarStyle = UIBarStyle(rawValue: navBarStyleInt) {
            self.navigationBarStyle = navBarStyle
        } else {
            self.navigationBarStyle = .default
        }
        
        if let tabBarStyleInt = details["tabBarStyle"] as? Int,
            let tabBarStyle = UIBarStyle(rawValue: tabBarStyleInt) {
            self.tabBarStyle = tabBarStyle
        } else {
            self.tabBarStyle = .default
        }
    }
    
}



/// A Theme Color Type string wrapper. These color types are dictionary keys for the correct
/// UIColor for the display of these items.
public struct ThemeColorType: RawRepresentable, Equatable, Hashable {
    
    /// Initializes the theme color.
    ///
    /// - Parameter rawValue: the raw string value representing the theme color.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// The raw value for the color. This is a String type.
    public let rawValue: String
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    // Tint
    public static let Tint                = ThemeColorType(rawValue: "tint")
    public static let NavigationBarTint   = ThemeColorType(rawValue: "navigationBarTint")
    
    // Text
    public static let PrimaryText         = ThemeColorType(rawValue: "primaryText")
    public static let SecondaryText       = ThemeColorType(rawValue: "secondaryText")
    public static let PlaceholderText     = ThemeColorType(rawValue: "placeholderText")
    
    // System
    public static let Background            = ThemeColorType(rawValue: "background")
    public static let Separator             = ThemeColorType(rawValue: "separator")
    public static let ValidationError       = ThemeColorType(rawValue: "validationError")
    public static let CellSelection         = ThemeColorType(rawValue: "cellSelection")
    public static let DisclosureIndicator   = ThemeColorType(rawValue: "disclosureIndicator")
    public static let PopoverBackground     = ThemeColorType(rawValue: "popoverBackground")
    public static let SearchField           = ThemeColorType(rawValue: "searchField")
    public static let SearchFieldBackground = ThemeColorType(rawValue: "searchFieldBackground")
    
    
    // Alternate colors - Dark when light, light when dark.
    public static let AlternatePrimaryText   = ThemeColorType(rawValue: "alternatePrimaryText")
    public static let AlternateSecondaryText = ThemeColorType(rawValue: "alternateSecondaryText")
    public static let AlternateSeparator     = ThemeColorType(rawValue: "alternateSeparator")
    
    // Grouped Table specific
    public static let GroupedTableBackground     = ThemeColorType(rawValue: "groupedTableBackground")
    public static let GroupedTableCellBackground = ThemeColorType(rawValue: "groupedTableCellBackground")
    public static let GroupedTableSeparator      = ThemeColorType(rawValue: "groupedTableSeparator")
}

public func ==(lhs: ThemeColorType, rhs: ThemeColorType) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
