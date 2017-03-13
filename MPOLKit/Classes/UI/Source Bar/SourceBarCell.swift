//
//  SourceBarCell.swift
//  Pods
//
//  Created by Rod Brown on 10/3/17.
//
//

import UIKit


internal class SourceBarCell: UIControl {
    
    fileprivate static let lightDisabledColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 0.2978102993)
    fileprivate static let darkDisabledColor  = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
    
    fileprivate let titleLabel = UILabel(frame: .zero)
    fileprivate let badgeView  = InterfaceBadgeView(frame: .zero)
    
    fileprivate var style: SourceBar.Style = .dark
    
    override var isSelected: Bool {
        didSet {
            badgeView.isHighlighted = isSelected || isHighlighted
            updateTextAttributes()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            badgeView.isHighlighted = isSelected || isHighlighted
            updateTextAttributes()
        }
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isAccessibilityElement = true
        
        backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.lineBreakMode      = .byTruncatingTail
        
        updateTextAttributes()
        
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.pulsesWhenHighlighted = true
        
        addSubview(badgeView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: badgeView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: badgeView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, constant: 33.0),
            
            NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, constant: 59.0),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, constant: 5.0)
        ])
    }
    
    internal func update(for item: SourceItem, withStyle style: SourceBar.Style) {
        self.style = style
        
        titleLabel.text = item.title
        accessibilityLabel = item.title
        
        isEnabled = item.isEnabled
        
        let badgeText: String
        if item.count < 10 {
            badgeText = String(describing: item.count)
        } else {
            badgeText = "9+"
        }
        
        accessibilityValue = item.count == 0 ? nil : "Count " + badgeText
        
        badgeView.text = badgeText
        badgeView.color = isEnabled ? item.color : style == .light ? SourceBarCell.lightDisabledColor : SourceBarCell.darkDisabledColor
        
        switch style {
        case .light: badgeView.glowAlpha = 0.1
        case .dark:  badgeView.glowAlpha = 0.3
        }
        
        updateTextAttributes()
    }
    
}

fileprivate extension SourceBarCell {
    fileprivate func updateTextAttributes() {
        let highlight = isSelected || isHighlighted
        
        switch style {
        case .light:
            titleLabel.textColor = isEnabled ? (highlight ? .darkGray : .gray)   : SourceBarCell.lightDisabledColor
        case .dark:
            titleLabel.textColor = isEnabled ? (highlight ? .white : .lightGray) : SourceBarCell.darkDisabledColor
        }
        
        titleLabel.font = highlight ? .systemFont(ofSize: 12.5, weight: UIFontWeightBold) : .systemFont(ofSize: 11.5, weight: UIFontWeightRegular)
    }
}
