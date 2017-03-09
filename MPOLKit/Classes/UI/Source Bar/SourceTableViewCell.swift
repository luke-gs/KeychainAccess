//
//  SourceTableViewCell.swift
//  Test
//
//  Created by Rod Brown on 13/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

internal class SourceTableViewCell: UITableViewCell {
    
    fileprivate static let lightDisabledColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 0.2978102993)
    fileprivate static let darkDisabledColor  = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
    
    fileprivate let titleLabel = UILabel(frame: .zero)
    fileprivate let badgeView  = InterfaceBadgeView(frame: .zero)
    
    fileprivate var isEnabled: Bool = true
    
    fileprivate var style: SourceBar.Style = .dark
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = self.contentView
        
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.lineBreakMode      = .byTruncatingTail
        
        updateTextAttributes()
        
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.pulsesWhenHighlighted = true
        
        contentView.addSubview(badgeView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: badgeView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX),
            NSLayoutConstraint(item: badgeView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .top, constant: 33.0),
            
            NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .top, constant: 59.0),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leading, constant: 5.0)
        ])
    }
    
    internal func update(for item: SourceItem, withStyle style: SourceBar.Style) {
        self.style = style
        
        titleLabel.text = item.title
        isEnabled = item.isEnabled
        
        let badgeText: String
        if item.count < 10 {
            badgeText = String(describing: item.count)
        } else {
            badgeText = "9+"
        }
        
        badgeView.text = badgeText
        badgeView.color = isEnabled ? item.color : style == .light ? SourceTableViewCell.lightDisabledColor : SourceTableViewCell.darkDisabledColor
        
        switch style {
        case .light: badgeView.glowAlpha = 0.1
        case .dark:  badgeView.glowAlpha = 0.3
        }
        
        updateTextAttributes()
    }
    
}

extension SourceTableViewCell {
    
    internal override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateTextAttributes()
    }
    
    internal override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateTextAttributes()
    }
    
}

fileprivate extension SourceTableViewCell {
    fileprivate func updateTextAttributes() {
        let highlight = isSelected || isHighlighted
        
        switch style {
        case .light:
            titleLabel.textColor = isEnabled ? (highlight ? .darkGray : .gray)   : SourceTableViewCell.lightDisabledColor
        case .dark:
            titleLabel.textColor = isEnabled ? (highlight ? .white : .lightGray) : SourceTableViewCell.darkDisabledColor
        }
        
        titleLabel.font = highlight ? .systemFont(ofSize: 12.5, weight: UIFontWeightBold) : .systemFont(ofSize: 11.5, weight: UIFontWeightRegular)
    }
}

extension SourceTableViewCell: DefaultReusable {
}
