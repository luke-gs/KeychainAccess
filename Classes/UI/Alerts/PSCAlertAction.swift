//
//  PSCAlertAction.swift
//  MPOLKit
//
//  Created by Kyle May on 6/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// The style to use to decorate a `PSCAlertAction`
///
/// - `default`: Default style, semibold blue text
/// - cancel: Indicates a cancel action, regular blue text
/// - destructive: Indicates a destructive action, semibold red text
/// - custom: uses a custom font and/or color. Will use the default style if `nil` supplied.
public enum PSCAlertActionStyle {
    
    case `default`
    case cancel
    case destructive
    case custom(font: UIFont?, color: UIColor?)
    
    /// The color to use for the style
    public var color: UIColor {
        switch self {
        case .destructive:
            return .orangeRed
        case .custom(_, let color):
            if let color = color {
                return color
            }
            fallthrough
        default:
            return .brightBlue
        }
    }
    
    /// The font to use for the style
    public var font: UIFont {
        switch self {
        case .cancel:
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        case .custom(let font, _):
            if let font = font {
                return font
            }
            fallthrough
        default:
            return UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
    }
}

/// An action for a PSCAlertController. This class mimics `UIKit`'s `UIAlertAction`.
open class PSCAlertAction {
    
    /// Completion handler upon selecting the action
    private var handler: ((PSCAlertAction) -> Swift.Void)?
    
    /// The title to use when displaying the action
    open private(set) var title: String?
    
    /// The style to use when displaying the action
    open private(set) var style: PSCAlertActionStyle
    
    open var isEnabled: Bool = true
    
    public init(title: String?, style: PSCAlertActionStyle, handler: ((PSCAlertAction) -> Swift.Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    /// Called when the action has been selected
    public func didSelect() {
        handler?(self)
    }
}
