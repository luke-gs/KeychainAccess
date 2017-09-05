//
//  NSMutableAttributedString+Extension.swift
//  MPOLKit
//
//  Created by Kyle May on 28/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {

    convenience init(_ text: String, font: UIFont? = nil, color: UIColor? = nil) {
        self.init(string: "")
        self.append(text, font: font, color: color)
    }
    
    /// Appends string with custom font and colour to existing attributed string
    @discardableResult
    func append(_ text: String, font: UIFont? = nil, color: UIColor? = nil) -> NSMutableAttributedString {
        var attributes: [String: Any] = [:]
        
        if let font = font {
            attributes[NSFontAttributeName] = font
        }
        
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        self.append(attributedString)
        return self
    }
    
    func append(attributedString: NSAttributedString) -> NSMutableAttributedString {
        self.append(attributedString)
        return self
    }
}
