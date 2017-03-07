//
//  SidebarTableViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 11/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// A UITableViewCell subclass for displaying items in a sidebar.
open class SidebarTableViewCell: UITableViewCell {
    
    fileprivate static let iconUnselectedColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    
    fileprivate var standardFont: UIFont?
    fileprivate var highlightedFont: UIFont?
    
    fileprivate var imageTintColor: UIColor?
    fileprivate var imageHighlightedTintColor: UIColor?
    
    fileprivate var isEnabled: Bool = true
    
    fileprivate var badgeView: SidebarBadgeView?
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        selectedBackgroundView = UIView(frame: .zero)
        reloadFonts()
    }
    
    
    /// Updates the cell with the content of the sidebar item.
    /// 
    /// Users should be aware that this does not create a link, and therefore changes to the
    /// sidebar item are not automatically translated to updates within the cell.
    ///
    /// - Parameter item: The `SidebarItem` to configure the cell for.
    open func update(for item: SidebarItem) {
        
        isEnabled = item.isEnabled
        
        if let imageView = self.imageView {
            imageView.image            = item.image ?? item.selectedImage
            imageView.highlightedImage = item.selectedImage ?? item.image
        }
        
        textLabel?.text = item.title
        
        if let detailLabel = detailTextLabel {
            let count = item.count
            detailLabel.text      = count != 0 ? String(describing: item.count) : nil
            detailLabel.textColor = isEnabled ? .lightGray : UIColor.lightGray.withAlphaComponent(0.2)
            detailLabel.isHidden  = count == 0
        }
        
        imageTintColor            = item.color
        imageHighlightedTintColor = item.selectedColor
        
        updateColors()
        
        if let badgeColor = item.badgeColor {
            // lazy load the badge view.
            let badgeView: SidebarBadgeView
            if let badge = self.badgeView {
                badgeView = badge
                badgeView.isHidden = false
            } else {
                badgeView = SidebarBadgeView(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 12.0))
                self.badgeView = badgeView
                contentView.addSubview(badgeView)
                setNeedsLayout()
            }
            badgeView.badgeColor = badgeColor
        } else {
            badgeView?.isHidden = true
        }
    }
    
}


/// Overrides
extension SidebarTableViewCell {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let badgeView = self.badgeView else { return }
        
        // Layout the badge view. Don't adjust it's size, just place it correctly in reference to the content views.
        if let imageView = self.imageView, imageView.image != nil {
            let referenceFrame = contentView.convert(imageView.frame, from: imageView.superview)
            badgeView.frame.origin = CGPoint(x: referenceFrame.maxX - 10.0, y: referenceFrame.minY - 2.0)
        } else if let textLabel = self.textLabel, textLabel.text?.isEmpty ?? true == false {
            let referenceFrame = contentView.convert(textLabel.frame, from: textLabel.superview)
            badgeView.frame.origin = CGPoint(x: referenceFrame.maxX - 4.0, y: referenceFrame.minY - 2.0)
        } else {
            badgeView.center = CGPoint(x: 6.0, y: bounds.midY)
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadFonts()
        updateColors()
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateFonts()
        updateColors()
    }
    
    open override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateFonts()
        updateColors()
    }
    
}


/// Content updates
fileprivate extension SidebarTableViewCell {
    
    private var currentTextColor: UIColor {
        let color: UIColor = isSelected || isHighlighted ? .white : .lightGray
        return isEnabled ? color : color.withAlphaComponent(0.2)
    }
    
    private var currentImageColor: UIColor {
        let color: UIColor
        if isSelected || isHighlighted {
            color = imageHighlightedTintColor ?? imageTintColor ?? .white
        } else {
            color = imageTintColor ?? SidebarTableViewCell.iconUnselectedColor
        }
        
        return isEnabled ? color : color.withAlphaComponent(0.2)
    }
    
    func reloadFonts() {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline, compatibleWith: traitCollection)
        standardFont = UIFont(descriptor: fontDescriptor, size: fontDescriptor.pointSize - 1)
        if let highlightedDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            highlightedFont = UIFont(descriptor: highlightedDescriptor, size: fontDescriptor.pointSize - 1)
        } else {
            highlightedFont = standardFont
        }
        detailTextLabel?.font = .preferredFont(forTextStyle: .caption1, compatibleWith: traitCollection)
    }
    
    func updateFonts() {
        if isSelected || isHighlighted {
            textLabel?.font = highlightedFont ?? standardFont
        } else {
            textLabel?.font = standardFont
        }
    }
    
    func updateColors() {
        imageView?.tintColor = currentImageColor
        textLabel?.textColor = currentTextColor
        detailTextLabel?.textColor = isEnabled ? .lightGray : UIColor.lightGray.withAlphaComponent(0.2)
    }
    
}

extension SidebarTableViewCell: DefaultReusable {
}


/// A private class to create the sidebar badge.
fileprivate class SidebarBadgeView: UIView {
    
    let borderColor: UIColor = #colorLiteral(red: 0.2279433608, green: 0.2033697367, blue: 0.2280697525, alpha: 1)
    var badgeColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .redraw
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        borderColor.setStroke()
        badgeColor?.setFill()
        
        let path = CGPath(ellipseIn: rect.insetBy(dx: 1.0, dy: 1.0), transform: nil)
        context.setLineWidth(2.0)
        context.addPath(path)
        context.drawPath(using: .fillStroke)
    }
    
}


