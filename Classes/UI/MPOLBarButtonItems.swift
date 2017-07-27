//
//  MPOLBarButtonItems.swift
//  MPOLKit
//
//  Created by Rod Brown on 25/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


extension UIBarButtonItem {
    
    /// A factory method to create a correctly configured back button item.
    ///
    /// - Parameters:
    ///   - target: The target for the action when selected.
    ///   - action: The action to fire at the target when selected.
    /// - Returns: A correctly configured UIBarButtonItem.
    public class func backBarButtonItem(target: AnyObject?, action: Selector?) -> UIBarButtonItem {
        let backItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .back), style: .plain, target: target, action: action)
        backItem.accessibilityLabel = NSLocalizedString("Back", comment: "Navigation bar button item accessibility")
        return backItem
    }
    
}



/// A UIBarButtonItem to toggle between the filtered and unfiltered state.
public class FilterBarButtonItem: UIBarButtonItem {
    
    /// A boolean value indicating whether the filter is active. The default is `false`.
    public var isActive: Bool = false {
        didSet {
            if isActive == oldValue { return }
            
            super.image = AssetManager.shared.image(forKey: isActive ? .filterFilled : .filter )
            
            if isActive {
                self.accessibilityValue = NSLocalizedString("Active", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
            } else {
                self.accessibilityValue = NSLocalizedString("Inactive", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
            }
            
        }
    }
    
    /// Initializes the `FilterBarButtonItem` with an optional target and action.
    ///
    /// - Parameters:
    ///   - target: The target for the action when selected.
    ///   - action: The action to fire at the target when selected.
    public init(target: AnyObject?, action: Selector?) {
        super.init()
        super.image = AssetManager.shared.image(forKey: .filter)
        self.target = target
        self.action = action
        self.accessibilityLabel = NSLocalizedString("Filter", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
        self.accessibilityValue = NSLocalizedString("Inactive", bundle: .mpolKit, comment: "Bar Button Item Accessibility.")
    }
    
    /// FilterBarButtonItem does not support NSCoding
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Setting the image is not supported.
    public override var image: UIImage? {
        get { return super.image }
        set { }
    }
    
    /// Setting the title is not supported.
    public override var title: String? {
        get { return super.title }
        set { }
    }
    
}
