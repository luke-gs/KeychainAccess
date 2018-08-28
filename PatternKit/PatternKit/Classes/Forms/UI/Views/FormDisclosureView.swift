//
//  FormDisclosureView.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

@available(iOS, deprecated, message: "Use FormAccessoryView with a disclosure style.")
public class FormDisclosureView: UIImageView {
    
    // The standard size of form disclosure views.
    public static let standardSize: CGSize = AssetManager.shared.image(forKey: .disclosure)!.size
    
    private static let defaultTintColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
    
    public override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set {
            if isThemeUpdatingEnabled {
                NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
                isThemeUpdatingEnabled = false
            }
            super.tintColor = newValue
        }
    }
    
    private var isThemeUpdatingEnabled: Bool = true
    
    
    // MARK: - Initializers
    
    public init() {
        let image = AssetManager.shared.image(forKey: .disclosure)!
        super.init(frame: CGRect(origin: .zero, size: image.size))
        super.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .disclosure) ?? FormDisclosureView.defaultTintColor
        super.image = image
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange(_:)), name: .interfaceStyleDidChange, object: nil)
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
    
    
    // MARK: - Private methods
    
    @objc private func interfaceStyleDidChange(_ notification: Notification) {
        super.tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .disclosure) ?? FormDisclosureView.defaultTintColor
    }
}

