//
//  SourceTableViewCell.swift
//  Test
//
//  Created by Rod Brown on 13/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class SourceTableViewCell: UITableViewCell {
    
    fileprivate static let disabledColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
    
    fileprivate let titleLabel = UILabel(frame: .zero)
    fileprivate let iconView   = SourceIcon(frame: .zero)
    fileprivate let glowView   = UIImageView(frame: .zero)
    
    fileprivate var isEnabled: Bool = true
    fileprivate var isGlowing: Bool = false
    fileprivate var glowColor: UIColor?
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = self.contentView
        
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 11.5, weight: UIFontWeightRegular)
        titleLabel.textColor = .lightGray
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.lineBreakMode      = .byTruncatingTail
        
        iconView.translatesAutoresizingMaskIntoConstraints   = false
        
        glowView.translatesAutoresizingMaskIntoConstraints   = false
        glowView.alpha = 0.4
        glowView.isHidden = true
        
        contentView.addSubview(glowView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: 33.0),
            
            glowView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: 59.0),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 5.0)
        ])
    }
    
    open func update(for item: SourceItem) {
        titleLabel.text = item.title
        
        if item.isEnabled == isEnabled && item.count == iconView.count && item.color == iconView.color {
            return // Do no updates if there's nothing to update.
        }
        
        isEnabled = item.isEnabled
        
        iconView.color     = isEnabled ? item.color : SourceTableViewCell.disabledColor
        iconView.count     = item.count
        
        updateGlow()
        
        if item.isEnabled == false {
            titleLabel.textColor = SourceTableViewCell.disabledColor
            titleLabel.font = .systemFont(ofSize: 11.5, weight: UIFontWeightRegular)
        }
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: 64.0, height: 88.0)
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateGlow()
    }
    
    open override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateGlow()
    }
    
}

extension SourceTableViewCell: DefaultReusable {
}


fileprivate extension SourceTableViewCell {
    
    fileprivate func updateGlow() {
        let shouldGlow = isSelected || isHighlighted
        
        guard shouldGlow, isEnabled, let glowColor = iconView.color else {
            if isEnabled {
                titleLabel.font = .systemFont(ofSize: 11.5, weight: UIFontWeightRegular)
                titleLabel.textColor = .lightGray
            }
            
            if isGlowing == false {
                /// We weren't glowing. Simply return.
                return
            }
            
            isGlowing = false
            
            // Hide glow - we either don't have a color or we're actively stopping glowing.
            glowView.layer.removeAnimation(forKey: "glow")
            glowView.alpha = 0.6
            glowView.isHidden = true
            
            return
        }
        
        if glowColor != self.glowColor {
            self.glowColor = glowColor
            self.glowView.image = nil//glowImage(withColor: glowColor)
        }
        
        // We're already glowing. Don't bother with the animation.
        if isGlowing { return }
        
        isGlowing = true
        glowView.isHidden = false
        
        // Create an animation that slowly fades the glow view in and out forever.
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.4
        animation.toValue = 1.0
        animation.repeatCount = .infinity
        animation.duration = 1.0
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        glowView.layer.add(animation, forKey: "glow")
        
        titleLabel.font = .systemFont(ofSize: 12.5, weight: UIFontWeightBold)
        titleLabel.textColor = .white
    }
    
    
//    private static let glowImageGenerator = UIGraphicsImageRenderer(size: CGSize(width: 60.0, height: 60.0))
//    
//    fileprivate func glowImage(withColor color: UIColor) -> UIImage {
//        let drawColor  = color.withAlphaComponent(0.3)
//        let clearColor = color.withAlphaComponent(0.0)
//        
//        return SourceTableViewCell.glowImageGenerator.image {_ in
//            let colors = [drawColor.cgColor, clearColor.cgColor]
//            
//            guard let context = UIGraphicsGetCurrentContext(),
//                let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil) else { return }
//            
//            let center = CGPoint(x: 30.0, y: 30.0)
//            
//            context.drawRadialGradient(gradient, startCenter: center, startRadius: 11.5, endCenter: center, endRadius: 30.0, options: [])
//        }
//    }
}

/// A UIView subclass for drawing the Source Icon itself.
fileprivate class SourceIcon: UIView {
    
    private var _isHighlighted: Bool = false
    
    @objc func isHighlighted() -> Bool {
        return _isHighlighted
    }
    
    @objc func setHighlighted(_ highlighted: Bool) {
        if _isHighlighted != highlighted {
            _isHighlighted = highlighted
            setNeedsDisplay()
        }
    }
    
    var color: UIColor? {
        didSet { if color != oldValue { setNeedsDisplay() } }
    }
    
    var count: UInt = 0 {
        didSet { if count != oldValue { setNeedsDisplay() } }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 30.0, height: 30.0)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let color: UIColor = self.color ?? .gray
        
        let count = self.count
        let text: NSString = count > 9 ? "9+" : String(describing: count) as NSString
        
        context.setLineWidth(1.0)
        color.set()
        
        let textAttributes: [String: Any]
        if _isHighlighted {
            context.fillEllipse(in: CGRect(x: 3.5, y: 3.5, width: 23.0, height: 23.0))
            
            color.withAlphaComponent(0.5).setStroke()
            context.strokeEllipse(in: CGRect(x: 0.5, y: 0.5, width: 29.0, height: 29.0))
            
            textAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13.0), NSForegroundColorAttributeName: UIColor.black]
        } else {
            context.strokeEllipse(in: CGRect(x: 5.5, y: 5.5, width: 19.0, height: 19.0))
            textAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 11.5), NSForegroundColorAttributeName: color]
        }
        
        let textSize = text.boundingRect(with: .max, attributes: textAttributes, context: nil).size
        
        var textRect =  CGRect(origin: CGPoint(x: 15.0 - textSize.width / 2.0, y: 14.5 - textSize.height / 2.0), size: textSize)
        if count > 9 {
            textRect.origin.x += 1.0
        }
        text.draw(in: textRect, withAttributes: textAttributes)
    }

}
