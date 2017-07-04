//
//  FormAccessoryCheckmark.swift
//  MPOLKit
//
//  Created by Rod Brown on 2/7/17.
//

import UIKit

/// A convenience class for creating a form accessory checkmark.
///
/// This class provides type-based checking to avoid re-creating an accessory where
/// one is already present, i.e.:
/// ```
/// cell.accessoryView = cell.accessoryView as? FormAccessoryCheckmark ?? FormAccessoryCheckmark()
/// ```
public class FormAccessoryCheckmark: UIImageView {

    // MARK: - Initializers
    
    public init() {
        let image = UIImage.formAccessoryCheckmark
        super.init(frame: CGRect(origin: .zero, size: image.size))
        super.image = image
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    
    // MARK: - Overrides
    
    public override var image: UIImage? {
        get { return super.image }
        set { }
    }
    
    public override var highlightedImage: UIImage? {
        get { return nil }
        set { }
    }
    
    public override var animationImages: [UIImage]? {
        get { return nil }
        set { }
    }
    
    public override var highlightedAnimationImages: [UIImage]? {
        get { return nil }
        set { }
    }
    

}
