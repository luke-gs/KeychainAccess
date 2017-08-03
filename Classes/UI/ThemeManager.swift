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
    public static let InterfaceStyleDidChange = NSNotification.Name(rawValue: "MPOL.InterfaceStyleDidChange")
}


@objc public enum UserInterfaceStyle: Int {
    
    case current
    
    case light
    
    case dark
    
}

public class ThemeManager {
    
    // MARK: - Singleton
    
    public static let shared: ThemeManager = ThemeManager()
    
    private init() {
    }
    
    
    // MARK: - Public  properties
    
    public var currentInterfaceStyle: UserInterfaceStyle = .light {
        didSet {
            if currentInterfaceStyle == .current || currentInterfaceStyle == oldValue {
                currentInterfaceStyle = oldValue
                return
            }
            
            // TODO: post notification
        }
    }
    
    
    // MARK: - Private properties
    
    private var registeredThemes = [UserInterfaceStyle: Theme]()
    
    private lazy var mpolLightTheme = Theme(details: [:])!
    
    private lazy var mpolDarkTheme = Theme(details: [:])!
    
    
    // MARK: - Theme access and registration
    
    public func register(_ theme: Theme?, for userInterfaceStyle: UserInterfaceStyle) {
        if userInterfaceStyle == .current || registeredThemes[userInterfaceStyle] == theme { return }
        
        registeredThemes[userInterfaceStyle] = theme
    }
    
    public func theme(for userInterfaceStyle: UserInterfaceStyle) -> Theme {
        var style = userInterfaceStyle
        if style == .current {
            style = currentInterfaceStyle
        }
        
        switch style {
        case .light: return registeredThemes[userInterfaceStyle] ?? mpolLightTheme
        case .dark:  return registeredThemes[userInterfaceStyle] ?? mpolDarkTheme
        default: fatalError("We should be able to get to this state - current is filtered out.")
        }
    }
    
}


