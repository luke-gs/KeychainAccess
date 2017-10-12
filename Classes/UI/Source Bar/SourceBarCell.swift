//
//  SourceBarCell.swift
//  MPOLKit
//
//  Created by Rod Brown on 10/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


internal class SourceBarCell: UIControl {
    
    private static let disabledColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
    private static let selectedFont  = UIFont.systemFont(ofSize: 11.5, weight: UIFont.Weight.bold)
    private static let normalFont    = UIFont.systemFont(ofSize: 11.5, weight: UIFont.Weight.regular)
    
    internal let titleLabel = UILabel(frame: .zero)
    
    private var _iconView: AlertIndicatorView?
    private var _loadingIndicator: UIActivityIndicatorView?
    private var _imageView: UIImageView?
    
    private var isAvailable: Bool = true
    
    private let iconLayoutGuide = UILayoutGuide()
    
    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var verticalContraints: [NSLayoutConstraint] = []
    
    private var highlightedTintColor: UIColor?
    private var normalTintColor: UIColor?
    
    var axis: SourceBar.Axis = .vertical {
        didSet {
            if axis == oldValue { return }
            
            let oldConstraints = axis == .vertical ? horizontalConstraints : verticalContraints
            let newConstraints = axis == .vertical ? verticalContraints : horizontalConstraints
            NSLayoutConstraint.deactivate(oldConstraints)
            NSLayoutConstraint.activate(newConstraints)
        }
    }
    
    
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
        
        addSubview(titleLabel)
        addLayoutGuide(iconLayoutGuide)
        
        verticalContraints = [
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topAnchor, constant: 59.0),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 5.0),
            
            iconLayoutGuide.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconLayoutGuide.centerYAnchor.constraint(equalTo: topAnchor, constant: 33.0),
        ]
        
        horizontalConstraints = [
            iconLayoutGuide.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconLayoutGuide.centerXAnchor.constraint(equalTo: leadingAnchor, constant: 12.0),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconLayoutGuide.centerXAnchor, constant: 22.0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
        ]
        
        switch axis {
        case .vertical:
            NSLayoutConstraint.activate(verticalContraints)
        case .horizontal:
            NSLayoutConstraint.activate(horizontalConstraints)
        }
        
        updateSelection()
    }
    
    
    // MARK: - Updates
    
    func update(for item: SourceItem) {
        accessibilityLabel = item.title
        
        if axis == .vertical {
            titleLabel.text = item.shortTitle ?? item.title
        } else {
            titleLabel.text = item.title
        }

        switch item.state {
        case .notLoaded:
            isEnabled = true
            
            let imageView = self.imageView()
            imageView.isHidden = false
            imageView.image = AssetManager.shared.image(forKey: .sourceBarDownload)
            
            highlightedTintColor = .white
            normalTintColor = .lightGray
            accessibilityValue  = nil
            
            _loadingIndicator?.stopAnimating()
            _iconView?.isHidden = true
            
            accessibilityTraits &= ~UIAccessibilityTraitNotEnabled
            accessibilityValue = "Not yet loaded."
        case .notAvailable:
            isEnabled = true
            
            let imageView = self.imageView()
            imageView.isHidden = false
            imageView.image = AssetManager.shared.image(forKey: .sourceBarNone)
            
            highlightedTintColor = SourceBarCell.disabledColor
            normalTintColor = SourceBarCell.disabledColor
            
            _loadingIndicator?.stopAnimating()
            _iconView?.isHidden = true
            
            accessibilityValue  = "Not available."
        case .loading:
            isEnabled = false
            
            let loadingIndicator = self.loadingIndicator()
            loadingIndicator.startAnimating()
            
            loadingIndicator.tintColor = .white
            highlightedTintColor = .white
            normalTintColor = .lightGray

            _imageView?.isHidden = true
            _iconView?.isHidden  = true
            
            accessibilityValue = "Loading"
            
        case .loaded(let count, let color):
            isEnabled = true
            
            let badgeText: String?
            if let count = count {
                if count < 10 {
                    badgeText = String(describing: count)
                } else {
                    badgeText = "9+"
                }
            } else { badgeText = nil }
            
            let iconView = self.iconView()
            iconView.isHidden = false
            iconView.text     = badgeText
            iconView.glowAlpha = 0.25
            
            highlightedTintColor = color ?? .white
            normalTintColor = color ?? .lightGray
            
            _imageView?.isHidden = true
            _loadingIndicator?.stopAnimating()
            
            if let count = count, count > 0 {
                accessibilityValue = "Count " + badgeText!
            } else {
                accessibilityValue = nil
            }
        }

        updateSelection()
    }
    
    private func updateSelection() {
        let highlight = isSelected || isHighlighted
        tintColor = highlight ? highlightedTintColor : normalTintColor
        titleLabel.textColor = isAvailable ? (highlight ? .white : .lightGray) : SourceBarCell.disabledColor
        titleLabel.font = highlight ? SourceBarCell.selectedFont : SourceBarCell.normalFont
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
            updateSelection()
            
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
            updateSelection()
        }
    }
    
    
    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        get {
            return sizeThatFits(.zero)
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        switch axis {
        case .vertical:
            return CGSize(width: 64.0, height: 77.0)
        case .horizontal:
            let titleSizing = StringSizing(string: titleLabel.text ?? "", font: SourceBarCell.selectedFont, numberOfLines: 1)
            let titleWidth = titleSizing.minimumWidth(compatibleWith: traitCollection)
            return CGSize(width: 34.0 + titleWidth, height: 56.0)
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
            imageView.centerXAnchor.constraint(equalTo: iconLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: iconLayoutGuide.centerYAnchor)
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
            iconView.centerXAnchor.constraint(equalTo: iconLayoutGuide.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconLayoutGuide.centerYAnchor)
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
            loadingIndicator.centerXAnchor.constraint(equalTo: iconLayoutGuide.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: iconLayoutGuide.centerYAnchor)
        ])
        return loadingIndicator
    }
    
}
