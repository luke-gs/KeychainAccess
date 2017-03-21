//
//  FormDisclosureView.swift
//  Pods
//
//  Created by Rod Brown on 19/3/17.
//
//

import UIKit

public class FormDisclosureView: UIImageView {
    
    fileprivate static var defaultTintColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
    
    public override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set {
            if isThemeUpdatingEnabled {
                NotificationCenter.default.removeObserver(self, name: .ThemeDidChange, object: nil)
            }
            super.tintColor = newValue
        }
    }
    
    fileprivate var isThemeUpdatingEnabled: Bool = true
    
    public init() {
        let image = UIImage.formDisclosureIndicator
        super.init(frame: CGRect(origin: .zero, size: image.size))
        super.tintColor = Theme.current.colors[.DisclosureIndicator] ?? FormDisclosureView.defaultTintColor
        super.image = image
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(_:)), name: .ThemeDidChange, object: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FormDisclosureView {
    
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

fileprivate extension FormDisclosureView {
    
    @objc fileprivate func themeDidChange(_ notification: Notification) {
        super.tintColor = Theme.current.colors[.DisclosureIndicator] ?? FormDisclosureView.defaultTintColor
    }
    
}
