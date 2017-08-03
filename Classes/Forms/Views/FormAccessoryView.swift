//
//  FormAccessoryView.swift
//  MPOLKit
//
//  Created by Rod Brown on 3/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public final class FormAccessoryView: UIImageView {

    public enum Style {
        case disclosure
        case dropDown
        case checkmark
        
        fileprivate var image: UIImage? {
            let key: AssetManager.ImageKey
            switch self {
            case .disclosure: key = .disclosure
            case .dropDown:   key = .dropDown
            case .checkmark:  key = .checkmark
            }
            return AssetManager.shared.image(forKey: key)
        }
    }
    
    private static var sizeCache: [Style: CGSize] = [:]
    
    public class func size(with style: Style) -> CGSize {
        if let size = sizeCache[style] { return size }
        
        let size = style.image?.size ?? .zero
        sizeCache[style] = size
        return size
    }
    
    
    // MARK: - Public properties
    
    public var style: Style? {
        didSet {
            if style != oldValue {
                super.image = style?.image
            }
        }
    }
    
    
    // MARK: - Initializers
    
    public init(style: Style) {
        let image = style.image
        super.init(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        super.image = image
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
