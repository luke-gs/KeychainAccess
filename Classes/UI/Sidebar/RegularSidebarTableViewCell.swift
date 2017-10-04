//
//  RegularSidebarTableViewCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 11/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// Regular size-class version of table view cell displaying navigation items in a vertical sidebar
open class RegularSidebarTableViewCell: UITableViewCell, DefaultReusable {
    
    public static let selectedColor        = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    public static let unselectedColor      = #colorLiteral(red: 0.5450980392, green: 0.568627451, blue: 0.6235294118, alpha: 1)
    public static let badgeBackgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1803921569, blue: 0.2117647059, alpha: 1)

    // MARK: - Private properties
    
    private var standardFont: UIFont?
    private var highlightedFont: UIFont?
    
    private var imageTintColor: UIColor?
    private var imageHighlightedTintColor: UIColor?
    
    private var isEnabled: Bool = true
    
    private var alertIcon: SidebarAlertIcon?
    
    private var badgeView: BadgeView?
    
    private var currentTextColor: UIColor {
        let color: UIColor = isSelected || isHighlighted ? RegularSidebarTableViewCell.selectedColor : RegularSidebarTableViewCell.unselectedColor
        return isEnabled ? color : color.withAlphaComponent(0.2)
    }
    
    private var currentImageColor: UIColor {
        let color: UIColor
        if isSelected || isHighlighted {
            color = imageHighlightedTintColor ?? imageTintColor ?? .white
        } else {
            color = imageTintColor ?? RegularSidebarTableViewCell.unselectedColor
        }
        
        return isEnabled ? color : color.withAlphaComponent(0.2)
    }
    
    
    // MARK: - Initializers
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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
    
    
    // MARK: - Updates
    
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
        
        textLabel?.text = item.regularTitle
        
        if let detailLabel = detailTextLabel {
            let count = item.count
            detailLabel.text      = count != 0 ? String(describing: item.count) : nil
            detailLabel.textColor = isEnabled ? .lightGray : UIColor.lightGray.withAlphaComponent(0.2)
            detailLabel.isHidden  = count == 0
        }
        
        let count = item.count
        if count > 0 {
            let badgeView: BadgeView
            if let badge = self.badgeView {
                badgeView = badge
            } else {
                let badge = BadgeView(style: .pill)
                badge.textColor = RegularSidebarTableViewCell.unselectedColor
                self.badgeView = badge
                badgeView = badge
            }
            badgeView.text = count < 100 ? String(describing: count) : "99+"
            badgeView.alpha = isEnabled ? 1.0 : 0.2
            badgeView.sizeToFit()
            accessoryView = badgeView
        } else {
            accessoryView = nil
        }
        
        imageTintColor            = item.color
        imageHighlightedTintColor = item.selectedColor
        
        updateColors()
        
        if let alertColor = item.alertColor {
            // lazy load the badge view.
            let alertIcon: SidebarAlertIcon
            if let icon = self.alertIcon {
                alertIcon = icon
                alertIcon.isHidden = false
            } else {
                alertIcon = SidebarAlertIcon(frame: CGRect(x: 0.0, y: 0.0, width: 12.0, height: 12.0))
                self.alertIcon = alertIcon
                contentView.addSubview(alertIcon)
                setNeedsLayout()
            }
            alertIcon.color = alertColor
        } else {
            alertIcon?.isHidden = true
        }
    }
    
    
    // MARK: - Overrides
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let alertIcon = self.alertIcon else { return }
        
        // Layout the badge view. Don't adjust it's size, just place it correctly in reference to the content views.
        if let imageView = self.imageView, imageView.image != nil {
            let referenceFrame = contentView.convert(imageView.frame, from: imageView.superview)
            alertIcon.frame.origin = CGPoint(x: referenceFrame.maxX - 10.0, y: referenceFrame.minY - 2.0)
        } else if let textLabel = self.textLabel, textLabel.text?.isEmpty ?? true == false {
            let referenceFrame = contentView.convert(textLabel.frame, from: textLabel.superview)
            alertIcon.frame.origin = CGPoint(x: referenceFrame.maxX - 4.0, y: referenceFrame.minY - 2.0)
        } else {
            alertIcon.center = CGPoint(x: 6.0, y: bounds.midY)
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
    
    
    // MARK: - Private methods
    
    private func reloadFonts() {
        detailTextLabel?.font = .preferredFont(forTextStyle: .caption1, compatibleWith: traitCollection)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline, compatibleWith: traitCollection)
        standardFont = UIFont(descriptor: fontDescriptor, size: fontDescriptor.pointSize - 1)
        if let highlightedDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            highlightedFont = UIFont(descriptor: highlightedDescriptor, size: fontDescriptor.pointSize - 1)
        } else {
            highlightedFont = standardFont
        }
    }
    
    private func updateFonts() {
        if isSelected || isHighlighted {
            textLabel?.font = highlightedFont ?? standardFont
        } else {
            textLabel?.font = standardFont
        }
    }
    
    private func updateColors() {
        imageView?.tintColor = currentImageColor
        textLabel?.textColor = currentTextColor
        badgeView?.backgroundColor = RegularSidebarTableViewCell.badgeBackgroundColor
    }
    
}



/// A private class to create the sidebar alert icon
fileprivate class SidebarAlertIcon: UIView {
    
    var color: UIColor?
    let borderColor: UIColor = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
    
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
        color?.setFill()
        
        let path = CGPath(ellipseIn: rect.insetBy(dx: 1.0, dy: 1.0), transform: nil)
        context.setLineWidth(2.0)
        context.addPath(path)
        context.drawPath(using: .fillStroke)
    }
    
}





