//
//  AlertIndicatorView.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// An indicator view for presenting alerts within the MPOL interface.
public class AlertIndicatorView: UIView {

    public var text: String? {
        get { return iconView.text }
        set { iconView.text = newValue }
    }
    
    public var glowAlpha: CGFloat = 0.3 {
        didSet {
            let glowAlpha = self.glowAlpha
            if glowAlpha ==~ oldValue { return }
            
            glowView.alpha           = glowAlpha
            glowAnimation?.fromValue = glowAlpha * 0.4
            glowAnimation?.toValue   = glowAlpha
        }
    }
    
    private var _isHighlighted: Bool = false
    @objc public var isHighlighted: Bool {
        get {
            return _isHighlighted
        }
        @objc(setHighlighted:) set {
            if _isHighlighted == newValue { return }
            
            _isHighlighted         = newValue
            iconView.isHighlighted = newValue
            glowView.isHidden      = !newValue
            
            if newValue {
                if pulsesWhenHighlighted {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
    
    public var pulsesWhenHighlighted: Bool = false {
        didSet {
            if pulsesWhenHighlighted != oldValue && _isHighlighted {
                isPulsing = pulsesWhenHighlighted
            }
        }
    }
    
    private var isPulsing: Bool = false {
        didSet {
            if isPulsing == oldValue {
                return
            }
            
            if (_isHighlighted == false || pulsesWhenHighlighted == false) && isPulsing {
                self.isPulsing = false
                return
            }
            
            if isPulsing {
                // Create an animation that slowly fades the glow view in and out forever.
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue    = glowAlpha * 0.4
                animation.toValue      = glowAlpha
                animation.repeatCount  = .infinity
                animation.duration     = 1.0
                animation.autoreverses = true
                animation.isRemovedOnCompletion = false
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                glowView.layer.add(animation, forKey: "glow")
                glowAnimation = animation
            } else {
                glowAnimation = nil
                glowView.layer.removeAnimation(forKey: "glow")
            }
        }
    }
    
    private let iconView = AlertIndicatorIconView(frame: .zero)
    
    private let glowView = AlertIndicatorGlowView(frame: .zero)
    
    private var glowAnimation: CABasicAnimation?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = false
        
        // We shouldn't get any smaller than the intrinsic content size, as it is the minimum for the badge view to appear correctly.
        setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        
        glowView.translatesAutoresizingMaskIntoConstraints = false
        glowView.isHidden = !_isHighlighted
        glowView.alpha    = glowAlpha
        addSubview(glowView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHighlighted = _isHighlighted
        addSubview(iconView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: glowView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: glowView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY),
            NSLayoutConstraint(item: iconView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY)
        ])
    }
    
    public override var intrinsicContentSize: CGSize {
        return iconView.intrinsicContentSize
    }
    
}



private class AlertIndicatorIconView: UIView {
    
    var isHighlighted: Bool = false {
        didSet {
            if isHighlighted != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    var text: String? {
        didSet { if text != oldValue { setNeedsDisplay() } }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        contentMode = .center
        isUserInteractionEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 30.0, height: 30.0)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let color: UIColor = self.tintColor ?? .gray
        
        context.setLineWidth(1.5)
        color.set()
        
        let bounds = self.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let textAttributes: [String: Any]
        let textYOffset: CGFloat
        if isHighlighted {
            context.fillEllipse(in: CGRect(x: center.x - 10.0, y: center.y - 10.0, width: 20.0, height: 20.0))
            
            color.withAlphaComponent(0.4).setStroke()
            
             context.strokeEllipse(in: CGRect(x: center.x - 14.0, y: center.y - 14.0, width: 28.0, height: 28.0))
            
            textAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13), NSForegroundColorAttributeName: UIColor.white]
            textYOffset = 0
        } else {
            context.strokeEllipse(in: CGRect(x: center.x - 9, y: center.y - 9, width: 18.0, height: 18.0))
            textAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10), NSForegroundColorAttributeName: color]
            textYOffset = 0.5
        }
        
        guard let string = text as NSString? else { return }
        
        let textSize = string.boundingRect(with: .max, attributes: textAttributes, context: nil).size
        let textRect =  CGRect(origin: CGPoint(x: center.x - (textSize.width / 2.0), y: center.y - textYOffset - (textSize.height / 2.0)), size: textSize)
        
        if isHighlighted {
            // In highlighted mode, we punch out the text in alpha, rather than drawing it directly.
            context.saveGState()
            context.setBlendMode(.clear)
            string.draw(in: textRect, withAttributes: textAttributes)
            context.restoreGState()
        } else {
            string.draw(in: textRect, withAttributes: textAttributes)
        }
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay()
    }
    
}

private class AlertIndicatorGlowView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = false
        contentMode = .redraw
        isOpaque = false
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
    
    override func draw(_ rect: CGRect) {
        let drawColor  = tintColor ?? .gray
        let clearColor = drawColor.withAlphaComponent(0.0)
        
        let colors = [drawColor.cgColor, clearColor.cgColor]
        
        guard let context = UIGraphicsGetCurrentContext(),
            let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil) else { return }
        
        let bounds = self.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        context.drawRadialGradient(gradient, startCenter: center, startRadius: 10, endCenter: center, endRadius: 25.0, options: [])
    }
    
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsDisplay(CGRect(x: bounds.midX - 30.0, y: bounds.midY - 30.0, width: 60.0, height: 60.0))
    }
    
}
