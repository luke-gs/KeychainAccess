//
//  UILabel+ContentObserving.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// KVO key paths for `UILabel`s that affect the laid out content size.
    internal static let contentKVOKeyPaths =  [
        #keyPath(UILabel.text),
        #keyPath(UILabel.font),
        #keyPath(UILabel.attributedText),
        #keyPath(UILabel.numberOfLines)
    ]
    
    
    /// Adds a key value observer for all key paths that are relevant to adjusting
    /// the `UILabel`'s content size. The key paths observed are included in `UILabel.contentKVOKeyPaths`.
    ///
    /// - Note: It is recommended you pair this method with it's removal method,
    ///         `UILabel.removeObserverForContentSizeKeys(_:context:)`.
    ///
    /// - Parameters:
    ///   - observer: Object to add as a KVO observer.
    ///   - options:  The key value observing options requested. The default is none.
    ///   - context:  The context to observe with. Unlike `NSObject.addObserver(_:forKeyPath:options:context:)`
    ///               the context is not nullable.
    internal func addObserverForContentSizeKeys(_ observer: NSObject, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer) {
        UILabel.contentKVOKeyPaths.forEach { self.addObserver(observer, forKeyPath: $0, options: options, context: context) }
    }
    
    
    
    /// Removes a key value observer for all key paths that are relevant to adjusting
    /// the `UILabel`'s content size. The key paths observed are included in `UILabel.contentKVOKeyPaths`.
    ///
    /// - Parameters:
    ///   - observer: Object to add as a KVO observer.
    ///   - context:  The context to observe with. Unlike `NSObject.removeObserver(_:forKeyPath:context:)`
    ///               the context is not nullable.
    internal func removeObserverForContentSizeKeys(_ observer: NSObject, context: UnsafeMutableRawPointer) {
        UILabel.contentKVOKeyPaths.forEach { self.removeObserver(observer, forKeyPath: $0, context: context) }
    }
    
}
