//
//  ThemeManager.swift
//  MPOLKit
//
//  Created by Rod Brown on 2/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


public extension NSNotification.Name {
    
    /// Posted when the current theme changes.
    public static let interfaceStyleDidChange = NSNotification.Name(rawValue: "MPOL.InterfaceStyleDidChange")
}


@objc public enum UserInterfaceStyle: Int {
    
    case current
    
    case light
    
    case dark
    
    
    // The key for persisted style in user defaults.
    private static let savedStyleKey = "savedUserInterfaceStyleKey"
    
    
    /// Returns whether this user interface style is dark.
    ///
    /// When .current, this checks the current interface style on the theme manager.
    public var isDark: Bool {
        switch self {
        case .dark:    return true
        case .light:   return false
        case .current: return ThemeManager.shared.currentInterfaceStyle == .dark
        }
    }
    
    
    /// Accessing & persisting the style saved in user defaults. Style is light by default.
    fileprivate static var savedStyle: UserInterfaceStyle {
        get {
            if let rawValue = AppGroupCapability.appUserDefaults.value(forKey: UserInterfaceStyle.savedStyleKey) as? Int {
                return UserInterfaceStyle(rawValue: rawValue) ?? .light
            } else {
                return .light
            }
        }
        set {
            AppGroupCapability.appUserDefaults.set(newValue.rawValue, forKey: UserInterfaceStyle.savedStyleKey)
        }
    }
    
}



/// The theme manager for MPOL apps.
///
/// The theme manager is a singleton and cannot be initialized directly,
/// and manages the current interface style (.light or .dark) for MPOL apps.
/// It also manages the currently set theme for each style. When not set,
/// the default is used.
@objcMembers
public class ThemeManager: NSObject {
    
    // MARK: - Singleton
    
    // The singleton `ThemeManager` instance
    public static let shared: ThemeManager = ThemeManager()
    
    private override init() {
        currentInterfaceStyle = UserInterfaceStyle.savedStyle
    }
    
    
    // MARK: - Public properties
    
    
    /// The current interface style. Changing this property fires a notification
    /// updating all observers that the interface style changed.
    public var currentInterfaceStyle: UserInterfaceStyle {
        didSet {
            if currentInterfaceStyle == .current || currentInterfaceStyle == oldValue {
                currentInterfaceStyle = oldValue
                return
            }
            
            NotificationCenter.default.post(name: .interfaceStyleDidChange, object: self)
            UserInterfaceStyle.savedStyle = currentInterfaceStyle
        }
    }
    
    
    // MARK: - Private properties

    private lazy var lightTheme = Theme(name: "LightTheme", in: .patternKit)!
    
    private lazy var darkTheme = Theme(name: "DarkTheme", in: .patternKit)!
    
    
    // MARK: - Theme access and registration
    
    
    /// Loads the interface style from user defaults.
    ///
    /// Call when app enters foreground to reload current style.
    public func loadInterfaceStyle() {
        currentInterfaceStyle = UserInterfaceStyle.savedStyle
    }
    
    
    /// Registers a theme with the manager.
    ///
    /// - Parameters:
    ///   - theme: The theme to register. If nil, returns to MPOL default theme.
    ///   - userInterfaceStyle: The interface style to register for. `.current` is ignored.
    public func register(_ theme: Theme?, for userInterfaceStyle: UserInterfaceStyle) {
        switch userInterfaceStyle {
        case .light: lightTheme = theme ?? Theme(name: "LightTheme", in: .patternKit)!
        case .dark:  darkTheme = theme ?? Theme(name: "DarkTheme", in: .patternKit)!
        case .current: break
        }
    }
    
    
    /// Accesses the current theme for the specified interface style
    ///
    /// - Parameter userInterfaceStyle: The interface style to request a theme for.
    ///             When specifying .current, the current style's theme is returned.
    /// - Returns: The correct theme for the interface style.
    public func theme(for userInterfaceStyle: UserInterfaceStyle) -> Theme {
        var style = userInterfaceStyle
        if style == .current {
            style = currentInterfaceStyle
        }
        switch style {
        case .light: return lightTheme
        case .dark:  return darkTheme
        default: fatalError("We should not be able to get to this state - current is filtered out.")
        }
    }
    
}
