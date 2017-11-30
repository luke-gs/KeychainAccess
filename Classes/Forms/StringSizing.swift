//
//  StringSizing.swift
//  MPOLKit
//
//  Created by Rod Brown on 15/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// An protocol representing items which can be converted into a `StringSizing`
/// type. `String` and `StringSizing` both implement this protocol.
public protocol StringSizable {
    
    func sizing() -> StringSizing
    
}

extension StringSizable {
    
    func sizing(defaultNumberOfLines: Int? = nil, defaultFont: UIFont? = nil) -> StringSizing {
        var sizing = self.sizing()
        
        if sizing.font == nil, let defaultFont = defaultFont {
            sizing.font = defaultFont
        }
        
        if sizing.numberOfLines == nil, let defaultNumberOfLines = defaultNumberOfLines {
            sizing.numberOfLines = defaultNumberOfLines
        }
        
        return sizing
    }
}

extension String: StringSizable {
    
    /// Returns a StringSizing initialized with the represented string.
    public func sizing() -> StringSizing {
        return StringSizing(string: self)
    }

    public func sizing(withNumberOfLines numberOfLines: Int?, font: UIFont? = nil) -> StringSizing {
        return StringSizing(string: self, font: font, numberOfLines: numberOfLines)
    }
    
}

public struct StringSizing: StringSizable {
    
    /// The base string for sizing.
    public var string: String
    
    /// The font for sizing. If you specify `nil`, the API receiving
    /// the sizing is responsible for specifying its default font.
    public var font: UIFont?
    
    /// The number of lines for sizing. If you specify `nil`, the API
    /// receiving the sizing is responsible for specifying the default
    /// line count. When `0`, no line limit is provided.
    public var numberOfLines: Int?
    
    
    /// Initializes a StringSizing struct.
    ///
    /// - Parameters:
    ///   - string:        The base string for the sizing.
    ///   - font:          The sizing font. The default is `nil`.
    ///   - numberOfLines: The number of lines. The default is `nil`.
    public init(string: String, font: UIFont? = nil, numberOfLines: Int? = nil) {
        self.string = string
        self.font = font
        self.numberOfLines = numberOfLines
    }
    
    
    /// Returns itself as its own StringSizing representation.
    public func sizing() -> StringSizing {
        return self
    }
    
    /// Calculates the minimum width required to fit the string based on the font and
    /// number of lines allowed.
    ///
    /// - Parameter traitCollection: The trait collection presentation environment.
    /// - Returns: The minimum width for the string.
    public func minimumWidth(compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        assert(self.font != nil, "StringSizing.font must not be nil when calculating sizes.")
        assert(self.numberOfLines != nil, "StringSizing.numberOfLines must not be nil when calculating sizes.")
        
        if string.isEmpty {
            return 0.0
        }
        
        let numberOfLines = self.numberOfLines!
        if numberOfLines <= 0 {
            // When their is no limitation on height (as in no line limit) then width limitations arent strict.
            return 10.0
        }

        let font = self.font!
        let displayScale = traitCollection.currentDisplayScale
        let maximumHeight = font.height(forNumberOfLines: numberOfLines).ceiled(toScale: displayScale)

        let size = (string as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: maximumHeight),
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: [NSAttributedStringKey.font: font],
                                                     context: nil)
        
        return size.width.ceiled(toScale: displayScale)
        
        // TODO: Perform binary search to find a width of text wrapping that fully fills the area.
        // 
        // if numberOfLines == 1 || size.height >= maximumHeight {
        //     return size.width.ceiled(toScale: displayScale)
        // }
        // MPLUnimplemented()
    }
    
    public func minimumHeight(inWidth width: CGFloat, allowingZeroHeight: Bool = true, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        assert(self.font != nil, "StringSizing.font must not be nil when calculating sizes.")
        assert(self.numberOfLines != nil, "StringSizing.numberOfLines must not be nil when calculating sizes.")
        
        let isEmptyString = string.isEmpty
        if isEmptyString && allowingZeroHeight {
            return 0.0
        }
        
        let font = self.font!
        let numberOfLines = self.numberOfLines!
        let displayScale = traitCollection.currentDisplayScale
        
        if isEmptyString || numberOfLines == 1 {
            return font.lineHeight.ceiled(toScale: displayScale)
        }
        
        let maximumHeight = font.height(forNumberOfLines: numberOfLines).ceiled(toScale: traitCollection.currentDisplayScale)
        let size = (string as NSString).boundingRect(with: CGSize(width: width, height: maximumHeight),
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: [NSAttributedStringKey.font: font],
                                                     context: nil)
        
        return min(size.height.ceiled(toScale: traitCollection.currentDisplayScale), maximumHeight)
    }
}

extension StringSizing: Equatable {

    /// StringSizing comparison.
    ///
    /// - Parameters:
    ///   - lhs: The StringSizing.
    ///   - rhs: The other StringSizing.
    /// - Returns: True if they are the same.
    public static func ==(lhs: StringSizing, rhs: StringSizing) -> Bool {
        return lhs.string == rhs.string &&
               lhs.font == rhs.font &&
               lhs.numberOfLines == rhs.numberOfLines
    }

}
