//
//  FontManager.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class FontManager: NSObject {
    
    public enum FontStyle: Int {
        case title1
        case title2
        case headline
        case button1
        case body1
        case body2
        case footnote1
        case footnote2
        case caption
        case button2
    }
    
    public static let shared = FontManager()
    
    private var cachedFonts: [FontKey: UIFont] = [:]
    
    private override init() {
        super.init()
    }
    
    public func font(withStyle style: FontStyle, compatibleWith traitCollection: UITraitCollection) -> UIFont {
        var category = UIContentSizeCategory.large
        var collection: UITraitCollection? = nil
        
        if traitCollection.preferredContentSizeCategory != .unspecified {
            category   = traitCollection.preferredContentSizeCategory
            collection = traitCollection
        }
        
        let fontKey = FontKey(style: style, category: category)
        
        if let font = cachedFonts[fontKey] { return font }
        
        let font = UIFont(descriptor: fontDescriptors(forStyle: style, compatibleWith: collection), size: 0.0)
        cachedFonts[fontKey] = font
        return font
    }
    
    private func fontDescriptors(forStyle style: FontStyle, compatibleWith traitCollection: UITraitCollection?) -> UIFontDescriptor {
        let textStyle: UIFontTextStyle
        var weightOverride: CGFloat? = nil
        
        switch style {
        case .title1:
            textStyle      = .title1
            weightOverride = UIFontWeightBold
        case .title2:
            textStyle      = .title2
            weightOverride = UIFontWeightBold
        case .headline:
            textStyle      = .headline
            weightOverride = UIFontWeightBold
        case .button1:
            textStyle      = .headline
        case .body1:
            textStyle      = .subheadline
            weightOverride = UIFontWeightSemibold
        case .body2:
            textStyle      = .subheadline
        case .footnote1:
            textStyle      = .footnote
            weightOverride = UIFontWeightMedium
        case .footnote2:
            textStyle      = .footnote
        case .caption:
            textStyle      = .caption2
        case .button2:
            textStyle      = .caption2
            weightOverride = UIFontWeightMedium
        }
        
        let baseDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle, compatibleWith: traitCollection)
        if let weightOverride = weightOverride {
            return baseDescriptor.addingAttributes([UIFontDescriptorTraitsAttribute: [UIFontWeightTrait: weightOverride]])
        }
        return baseDescriptor
    }
    
}


fileprivate struct FontKey: Equatable, Hashable {
    var style: FontManager.FontStyle
    var category: UIContentSizeCategory
    
    public static func ==(lhs: FontKey, rhs: FontKey) -> Bool{
        return lhs.style == rhs.style && lhs.category == rhs.category
    }
    
    var hashValue: Int {
        return category.hashValue
    }
}
