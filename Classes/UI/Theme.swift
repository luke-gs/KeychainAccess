//
//  Theme.swift
//  MPOLKit
//
//  Created by Rod Brown on 15/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class Theme: NSObject {
    
    // MARK: - Public properties
    
    /// The bundle containing the theme. This bundle should contain all images for the
    /// imageKeys in the theme.
    public let bundle: Bundle
    
    /// The status bar style appropriate for the assigned navigation bar style and color.
    public let statusBarStyle: UIStatusBarStyle
    
    /// The navigation bar style. When there is a background image set, this adjusts the
    /// title details etc.
    public let navigationBarStyle: UIBarStyle
    
    /// The tab bar style.
    public let tabBarStyle: UIBarStyle
    
    
    // MARK: - Private properties
    
    private let colors: [ColorKey: UIColor]
    
    private let imageNames: [ImageKey: String]
    
    
    // MARK: - Initializers
    
    public init(details: [String: Any], bundle: Bundle) {
        self.bundle = bundle
        
        if let statusBarRawValue = details["statusBarStyle"] as? Int,
            let statusBarStyle = UIStatusBarStyle(rawValue: statusBarRawValue) {
            self.statusBarStyle = statusBarStyle
        } else {
            self.statusBarStyle = .default
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
        
        var colors: [ColorKey: UIColor] = [:]
        (details["colors"] as? [String: String])?.forEach { (key: String, hex: String) in
            if let color = UIColor(hexString: hex) {
                colors[ColorKey(key)] = color
            }
        }
        self.colors = colors
        
        var imageNames: [ImageKey: String] = [:]
        (details["images"] as? [String: String])?.forEach {  (key: String, name: String) in
            imageNames[ImageKey(key)] = name
        }
        self.imageNames = imageNames
    }
    
    public convenience init?(name: String, in bundle: Bundle) {
        guard let fileURL = bundle.url(forResource: name, withExtension: "json"),
              let details = (try? JSONSerialization.jsonObject(with: Data(contentsOf: fileURL))) as? [String: Any]
            else { return nil }
        
        self.init(details: details, bundle: bundle)
    }
    
    
    // MARK: - Accessors
    
    public func color(forKey key: ColorKey) -> UIColor? {
        return colors[key]
    }
    
    public func image(forKey key: ImageKey, compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        guard let imageName = imageNames[key] else { return nil }
        return UIImage(named: imageName, in: bundle, compatibleWith: traitCollection)
    }
}



// MARK: - Keys

extension Theme {
    
    /// A struct wrapping the concept of a ColorKey.
    ///
    /// These color types are dictionary keys for the correct
    /// UIColor for the display of these items.
    public struct ColorKey: RawRepresentable, Hashable {
        
        // Book-keeping
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
        
        // Tint
        public static let tint                = ColorKey(rawValue: "tint")
        public static let navigationBarTint   = ColorKey(rawValue: "navigationBarTint")
        
        // Text
        public static let primaryText         = ColorKey(rawValue: "primaryText")
        public static let secondaryText       = ColorKey(rawValue: "secondaryText")
        public static let placeholderText     = ColorKey(rawValue: "placeholderText")
        
        // System
        public static let background            = ColorKey(rawValue: "background")
        public static let separator             = ColorKey(rawValue: "separator")
        public static let validationError       = ColorKey(rawValue: "validationError")
        public static let cellSelection         = ColorKey(rawValue: "cellSelection")
        public static let disclosure            = ColorKey(rawValue: "disclosure")
        public static let popoverBackground     = ColorKey(rawValue: "popoverBackground")
        public static let searchField           = ColorKey(rawValue: "searchField")
        public static let searchFieldBackground = ColorKey(rawValue: "searchFieldBackground")
        
        // Grouped Table specific
        public static let groupedTableBackground     = ColorKey(rawValue: "groupedTableBackground")
        public static let groupedTableCellBackground = ColorKey(rawValue: "groupedTableCellBackground")
        
    }
    
    public struct ImageKey: RawRepresentable, Hashable {
        
        // Book-keeping
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public var hashValue: Int {
            return rawValue.hashValue
        }
        
        // Nav Bar
        public static let navigationBarBackground = ImageKey("navigationBar")
        public static let navigationBarExtension  = ImageKey("navigationBarExtension")
        public static let navigationBarShadow     = ImageKey("navigationBarShadow")
    }
}

public func ==(lhs: Theme.ColorKey, rhs: Theme.ColorKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public func ==(lhs: Theme.ImageKey, rhs: Theme.ImageKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}


// MARK: - Deprecated

extension Theme {
    
    // The current theme.
    @available(iOS, deprecated, message: "Use `ThemeManager.shared.theme(for: .current`")
    public class var current: Theme {
        return ThemeManager.shared.theme(for: .current)
    }
    
    
    /// The navigation bar background image.
    @available(iOS, deprecated, message: "Use `image(forKey: .navigationBarBackground)`")
    public var navigationBarBackgroundImage: UIImage? {
        return image(forKey: .navigationBarBackground)
    }
    
    /// The navigation bar shadow image. This should be shared between the actual navigation
    /// bar, and any associated navigation bar background extensions
    @available(iOS, deprecated, message: "Use `image(forKey: .navigationBarShadow)`")
    public var navigationBarShadowImage: UIImage? {
        return image(forKey: .navigationBarShadow)
    }
    
    /// The background image for an extension of the navigation bar
    @available(iOS, deprecated, message: "Use `image(forKey: .navigationBarExtension)`")
    public var navigationBarBackgroundExtensionImage: UIImage? {
        return image(forKey: .navigationBarExtension)
    }
    
}
