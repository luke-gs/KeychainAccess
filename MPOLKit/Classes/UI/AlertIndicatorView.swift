//
//  AlertIndicatorView.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A an indicator view for presenting alerts within the MPOL interface.
public class AlertIndicatorView: UIView {

    public var text: String? {
        get { return iconView.text }
        set { iconView.text = newValue }
    }
    
    @NSCopying public var color: UIColor! = .gray {
        didSet {
            let color: UIColor
            if let setColor = self.color {
                color = setColor
            } else {
                color = .gray
                self.color = .gray
            }
            
            if color == oldValue { return }
            
            iconView.color = color
            glowView.color = color
        }
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
    
    fileprivate var isPulsing: Bool = false {
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
    
    fileprivate let iconView = InterfaceBadgeIcon(frame: .zero)
    
    fileprivate let glowView = InterfaceBadgeGlow(frame: .zero)
    
    fileprivate var glowAnimation: CABasicAnimation?
    
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
        glowView.color    = color
        glowView.isHidden = !_isHighlighted
        glowView.alpha    = glowAlpha
        addSubview(glowView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHighlighted = _isHighlighted
        iconView.color         = color
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



fileprivate class InterfaceBadgeIcon: UIView {
    
    var isHighlighted: Bool = false {
        didSet {
            if isHighlighted != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    @NSCopying var color: UIColor? {
        didSet { if color != oldValue { setNeedsDisplay() } }
    }
    
    var text: String? {
        didSet { if text != oldValue { setNeedsDisplay() } }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .center
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        contentMode = .center
        isUserInteractionEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 30.0, height: 30.0)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let color: UIColor = self.color ?? .gray
        
        context.setLineWidth(1.0)
        color.set()
        
        let bounds = self.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let textAttributes: [String: Any]
        if isHighlighted {
            context.fillEllipse(in: CGRect(x: center.x - 11.5, y: center.y - 11.5, width: 23.0, height: 23.0))
            
            color.withAlphaComponent(0.5).setStroke()
            context.strokeEllipse(in: CGRect(x: center.x - 14.5, y: center.y - 14.5, width: 29.0, height: 29.0))
            
            textAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13.0), NSForegroundColorAttributeName: UIColor.white]
        } else {
            context.strokeEllipse(in: CGRect(x: center.x - 9.5, y: center.y - 9.5, width: 19.0, height: 19.0))
            textAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 11.5), NSForegroundColorAttributeName: color]
        }
        
        guard let string = text as NSString? else { return }
        
        let textSize = string.boundingRect(with: .max, attributes: textAttributes, context: nil).size
        let textRect =  CGRect(origin: CGPoint(x: center.x - textSize.width / 2.0, y: center.y - 0.5 - (textSize.height / 2.0)), size: textSize)
        
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
    
}

fileprivate class InterfaceBadgeGlow: UIView {
    
    @NSCopying var color: UIColor? {
        didSet {
            if color == oldValue { return }
            
            let bounds = self.bounds
            setNeedsDisplay(CGRect(x: bounds.midX - 30.0, y: bounds.midY - 30.0, width: 60.0, height: 60.0))
        }
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
        isUserInteractionEnabled = false
        contentMode = .redraw
        isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        let drawColor  = color ?? .gray
        let clearColor = drawColor.withAlphaComponent(0.0)
        
        let colors = [drawColor.cgColor, clearColor.cgColor]
        
        guard let context = UIGraphicsGetCurrentContext(),
            let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil) else { return }
        
        let bounds = self.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        context.drawRadialGradient(gradient, startCenter: center, startRadius: 11.5, endCenter: center, endRadius: 30.0, options: [])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
    
}
