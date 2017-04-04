//
//  SourceBarCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 10/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


internal class SourceBarCell: UIControl {
    
    private static let lightDisabledColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 0.2978102993)
    private static let darkDisabledColor  = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
    
    private let titleLabel = UILabel(frame: .zero)
    
    private var _iconView: AlertIndicatorView?
    private var _loadingIndicator: UIActivityIndicatorView?
    private var _imageView: UIImageView?
    
    private var style: SourceBar.Style = .dark
    
    private var isAvailable: Bool = true
    
    // MARK: - Initializers
    
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
        
        // Add this value to avoid caching contents - as we may update counts or states
        // - and instead let the accessibility trait be deduced as updated.
        accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently
        
        backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.lineBreakMode      = .byTruncatingTail
        updateTextAttributes()
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, constant: 59.0),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, constant: 5.0)
        ])
    }
    
    
    // MARK: - Updates
    
    func update(for item: SourceItem, withStyle style: SourceBar.Style) {
        self.style = style
        
        titleLabel.text    = item.title
        accessibilityLabel = item.title
        
        isEnabled = item.state != .notAvailable
        switch item.state {
        case .notLoaded:
            isEnabled = true
            
            let imageView = self.imageView()
            imageView.isHidden = false
            imageView.image = UIImage(named: "SourceBarDownload", in: .mpolKit, compatibleWith: traitCollection)
            
            tintColor = style == .dark ? .white: .black
            accessibilityValue  = nil
            
            _loadingIndicator?.stopAnimating()
            _iconView?.isHidden = true
            
            accessibilityTraits &= ~UIAccessibilityTraitNotEnabled
            accessibilityValue = "Not yet loaded."
        case .notAvailable:
            isEnabled = false
            
            let imageView = self.imageView()
            imageView.isHidden = false
            imageView.image = UIImage(named: "TempSourceBarNotAvailable", in: .mpolKit, compatibleWith: traitCollection)
            
            tintColor = style == .dark ? SourceBarCell.darkDisabledColor : SourceBarCell.lightDisabledColor
            
            _loadingIndicator?.stopAnimating()
            _iconView?.isHidden = true
            
            accessibilityValue  = "Not available."
        case .loading:
            isEnabled = false
            
            let loadingIndicator = self.loadingIndicator()
            loadingIndicator.startAnimating()
            
            if style == .dark {
                loadingIndicator.tintColor = .white
                tintColor = .white
            } else {
                loadingIndicator.tintColor = .gray
                tintColor = .black
            }
            
            _imageView?.isHidden = true
            _iconView?.isHidden  = true
            
            accessibilityValue = "Loading"
            
        case .loaded(let count, let color):
            isEnabled = true
            
            let badgeText: String
            if count < 10 {
                badgeText = String(describing: count)
            } else {
                badgeText = "9+"
            }
            
            let iconView = self.iconView()
            iconView.isHidden = false
            iconView.text     = badgeText
            switch style {
            case .light: iconView.glowAlpha = 0.1
            case .dark:  iconView.glowAlpha = 0.3
            }
            
            tintColor = color
            
            _imageView?.isHidden = true
            _loadingIndicator?.stopAnimating()
            
            accessibilityValue = count == 0 ? nil : "Count " + badgeText
        }
        
        isAvailable = item.state != .notAvailable
        
        updateTextAttributes()
    }
    
    private func updateTextAttributes() {
        let highlight = isSelected || isHighlighted
        
        switch style {
        case .light:
            titleLabel.textColor = isAvailable ? (highlight ? .darkGray : .gray)   : SourceBarCell.lightDisabledColor
        case .dark:
            titleLabel.textColor = isAvailable ? (highlight ? .white : .lightGray) : SourceBarCell.darkDisabledColor
        }
        
        titleLabel.font = highlight ? .systemFont(ofSize: 12.5, weight: UIFontWeightBold) : .systemFont(ofSize: 11.5, weight: UIFontWeightRegular)
    }
    
    
    // MARK: - State overrides
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                accessibilityTraits &= ~UIAccessibilityTraitNotEnabled
            } else {
                accessibilityTraits |= UIAccessibilityTraitNotEnabled
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            _iconView?.isHighlighted = isSelected || isHighlighted
            updateTextAttributes()
            
            if isSelected {
                accessibilityTraits |= UIAccessibilityTraitSelected
            } else {
                accessibilityTraits &= ~UIAccessibilityTraitSelected
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            _iconView?.isHighlighted = isSelected || isHighlighted
            updateTextAttributes()
        }
    }
    
    
    // MARK: - Lazy loading
    
    private func imageView() -> UIImageView {
        if let imageView = _imageView { return imageView }
        
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        _imageView = imageView
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, constant: 33.0),
        ])
        return imageView
    }
    
    private func iconView() -> AlertIndicatorView {
        if let iconView = _iconView { return iconView }
        
        let iconView = AlertIndicatorView(frame: .zero)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHighlighted = isSelected || isHighlighted
        addSubview(iconView)
        _iconView = iconView
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: iconView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, constant: 33.0),
        ])
        return iconView
    }
    
    private func loadingIndicator() -> UIActivityIndicatorView {
        if let loadingIndicator = _loadingIndicator { return loadingIndicator }
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)
        _loadingIndicator = loadingIndicator
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: loadingIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: loadingIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, constant: 33.0),
        ])
        return loadingIndicator
    }
    
}
