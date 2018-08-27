//
//  NSAttributedString+IfExists.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

extension NSAttributedString {

    /// Checks if the passed in location (index) exists before attempting to retrieve attributes at location
    /// If so returns nil
    public func attributesIfExist(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any]? {

        guard self.length > location else {
            return nil
        }
        return attributes(at: location, effectiveRange: range)
    }

    /// Checks if the passed in location (index) exists before attempting to retrieve named attribute at location
    /// If so returns nil
    public func attributeIfExists(_ attrName: NSAttributedStringKey, at location: Int, effectiveRange range: NSRangePointer?) -> Any? {

        guard self.length > location else {
            return nil
        }
        return attribute(attrName, at: location, effectiveRange: range)
    }
}
