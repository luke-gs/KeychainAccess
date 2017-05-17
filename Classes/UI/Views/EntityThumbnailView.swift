//
//  EntityThumbnailView.swift
//  MPOLKit
//
//  Created by Rod Brown on 20/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A view for displaying entity thumbnails within an MPOL interface.
public class EntityThumbnailView: UIControl {
    
    public let backgroundImageView = UIImageView(frame: .zero)
    
    public let imageView = UIImageView(frame: .zero)
    
    /// The border color.
    ///
    /// When this value is `nil`, the border is automatically hidden.
    /// The default is `nil`.
    @NSCopying public var borderColor: UIColor? {
        didSet {
            if borderColor == oldValue { return }
            
            layer.borderColor = borderColor?.cgColor
            if borderWidth > 0 {
                updateCornerRadius()
            }
        }
    }
    
    
    /// The border width.
    ///
    /// When this value is zero, the border is autmatically hidden.
    /// The default is 2.0.
    public var borderWidth: CGFloat = 2.0 {
        didSet {
            if borderWidth != oldValue && borderColor != nil {
                updateCornerRadius()
            }
        }
    }
    
    
    // MARK: - Private properties
    
    private lazy var highlightView: UIView = { [unowned self] in
        defer { self.isHighlightViewLoaded = true }
        
        let highlightView = UIView(frame: self.backgroundImageView.bounds)
        highlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        highlightView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2980303697)
        highlightView.isHidden = self.isHighlighted == false && self.isEnabled
        self.backgroundImageView.addSubview(highlightView)
        return highlightView
    }()
    
    private var isHighlightViewLoaded = false
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundImageView.frame = bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        addSubview(backgroundImageView)
        
        imageView.frame = backgroundImageView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.addSubview(imageView)
        
        updateCornerRadius()
        
        layer.rasterizationScale = traitCollection.currentDisplayScale
        layer.shouldRasterize = true
        
        accessibilityTraits |= UIAccessibilityTraitButton
        isEnabled = false
        
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    
    // MARK: - Configuration
    
    public func configure(for entity: Any) {
        // TODO: Configure for real entities
        backgroundImageView.image = #imageLiteral(resourceName: "Avatar 1")
        borderColor = AlertLevel.high.color
    }
    
    
    // MARK: - Overrides
    
    public override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                updateCornerRadius()
            }
        }
    }
    
    public override var frame: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                updateCornerRadius()
            }
        }
    }
    
    public override var isEnabled: Bool {
        didSet { updateHighlight() }
    }
    
    public override var isHighlighted: Bool {
        didSet { updateHighlight() }
    }
    
    public override var intrinsicContentSize: CGSize {
        return imageView.intrinsicContentSize
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layer.rasterizationScale = traitCollection.currentDisplayScale
    }
    
    
    // MARK: - Private methods
    
    private func updateCornerRadius() {
        let bounds = self.bounds
        let cornerRadius = ((min(bounds.width, bounds.height) + 300.0) / 80.0).rounded(toScale: (window?.screen ?? .main).scale)
        
        layer.cornerRadius = cornerRadius
        
        if borderColor == nil || borderWidth == 0.0 {
            backgroundImageView.layer.cornerRadius = cornerRadius
            backgroundImageView.frame = bounds
            layer.borderWidth = 0.0
        } else {
            backgroundImageView.layer.cornerRadius = max(cornerRadius - 3.0, 0.0)
            backgroundImageView.frame = bounds.insetBy(dx: 4.0, dy: 4.0)
            layer.borderWidth = borderWidth
        }
    }
    
    private func updateHighlight() {
        if isHighlightViewLoaded || isHighlighted {
            highlightView.isHidden = isHighlighted == false && isEnabled
        }
    }
    
    @objc private func touchUpInside() {
        sendActions(for: .primaryActionTriggered)
    }
    
}
