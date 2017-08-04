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
    
}

public class ThemeManager {
    
    // MARK: - Singleton
    
    public static let shared: ThemeManager = ThemeManager()
    
    private init() {
    }
    
    
    // MARK: - Public properties
    
    public var currentInterfaceStyle: UserInterfaceStyle = .light {
        didSet {
            if currentInterfaceStyle == .current || currentInterfaceStyle == oldValue {
                currentInterfaceStyle = oldValue
                return
            }
            
            NotificationCenter.default.post(name: .interfaceStyleDidChange, object: self)
        }
    }
    
    
    // MARK: - Private properties
    
    private var registeredThemes = [UserInterfaceStyle: Theme]()
    
    private lazy var lightTheme = Theme(name: "LightTheme", in: .mpolKit)!
    
    private lazy var darkTheme = Theme(name: "DarkTheme", in: .mpolKit)!
    
    
    // MARK: - Theme access and registration
    
    public func register(_ theme: Theme, for userInterfaceStyle: UserInterfaceStyle) {
        switch userInterfaceStyle {
        case .light: lightTheme = theme
        case .dark:  darkTheme = theme
        case .current: break
        }
    }
    
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
