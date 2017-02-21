//
//  CollectionViewFormRadioButtonCell.swift
//  MPOLKit/FormKit
//
//  Created by Ryan Wu on 10/11/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

private var textContext = 1

/**
 A simple cell class containing a radio box.
 The radio's selection is determined by selection status of the cell.
 */
open class CollectionViewFormRadioButtonCell: CollectionViewFormCell {
    
    class func minimumContentWidth(withTitle title: String?) -> CGFloat {
        let titleSize = ceil((title as NSString?)?.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)]).width ?? 0 + 30.0)
        return titleSize
    }
    
    open let textLabel  = UILabel(frame: .zero)
    open let titleLabel = UILabel(frame: .zero)
    
    fileprivate let imageView = UIImageView(frame: .zero)
    
    /// The radio box inset within the layout margins.
    /// The default is an inset of 10.0 at the left, and zero on all other sides.
    open var radioBoxInset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0) {
        didSet { if radioBoxInset != oldValue { setNeedsLayout() } }
    }
    
    /// The enabled appearance of the radio box.
    /// When disabled, an alpha of 0.5 is applied to the radio box and its text label.
    open var isEnabled: Bool = true {
        didSet {
            if isEnabled == oldValue { return }
            let alpha: CGFloat = isEnabled ? 1.0 : 0.5
            titleLabel.alpha = alpha
            textLabel.alpha  = alpha
            imageView.alpha  = alpha
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        func addObserver(for label: UILabel) {
            label.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: [], context: &textContext)
            label.addObserver(self, forKeyPath: #keyPath(UILabel.font), options: [], context: &textContext)
            label.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), options: [], context: &textContext)
            label.addObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines),  options: [], context: &textContext)
        }
        
        let contentView = self.contentView
        
        titleLabel.font               = .systemFont(ofSize: 14.5, weight: UIFontWeightSemibold)
        titleLabel.lineBreakMode      = .byTruncatingTail
        titleLabel.minimumScaleFactor = 0.9
        
        textLabel.font               = .systemFont(ofSize: 14.5, weight: UIFontWeightSemibold)
        textLabel.lineBreakMode      = .byTruncatingTail
        textLabel.minimumScaleFactor = 0.9
        
        addObserver(for: titleLabel)
        addObserver(for: textLabel)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textLabel)
        contentView.addSubview(imageView)
        
        updateImageView()
        updateImageTint()
    }
    
    deinit {
        func removeObserver(for label: UILabel) {
            label.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &textContext)
            label.removeObserver(self, forKeyPath: #keyPath(UILabel.font), context: &textContext)
            label.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &textContext)
            label.removeObserver(self, forKeyPath: #keyPath(UILabel.numberOfLines),  context: &textContext)
        }
        
        removeObserver(for: textLabel)
        removeObserver(for: titleLabel)
    }
}


/// Overrides
extension CollectionViewFormRadioButtonCell {
    
    open override var isSelected: Bool {
        didSet {
            updateImageView()
            updateImageTint()
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            updateImageTint()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentView = self.contentView
        let contentInsets = contentView.layoutMargins
        
        let contentRect = contentView.bounds.insetBy(contentInsets).insetBy(radioBoxInset)
        
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: contentRect.size.width - 10.0, height: contentRect.size.height))
        
        let titleLabelFrame = CGRect(x: contentInsets.left, y: contentRect.minY, width: contentRect.width, height: titleLabelSize.height)
        if titleLabel.frame != titleLabelFrame {
            titleLabel.frame = titleLabelFrame
        }
        
        var imageViewFrame = imageView.frame
        imageViewFrame.origin.x = contentInsets.left
        imageViewFrame.size = imageView.image?.size ?? .zero
        
        let radioHeight = contentRect.size.height - titleLabelSize.height
        imageViewFrame.origin.y = (titleLabelSize.height + contentRect.minY + (radioHeight - imageViewFrame.size.height) / 2.0).rounded(toScale: UIScreen.main.scale)
        if imageView.frame != imageViewFrame {
            imageView.frame = imageViewFrame
        }
        
        let textLabelSize = textLabel.sizeThatFits(CGSize(width: contentRect.size.width - 10.0 - imageViewFrame.size.width, height: contentRect.size.height))
        
        let textLabelFrame = CGRect(x: imageViewFrame.maxX + 10.0, y: (titleLabelSize.height + contentRect.minY + (radioHeight - textLabelSize.height) / 2.0).rounded(toScale: UIScreen.main.scale), width: textLabelSize.width, height: textLabelSize.height)
        if textLabel.frame != textLabelFrame {
            textLabel.frame = textLabelFrame
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &textContext {
            setNeedsLayout()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

/// Private methods
fileprivate extension CollectionViewFormRadioButtonCell {
    
    fileprivate func updateImageView() {
        imageView.image = isSelected ? .radioButtonSelected : .radioButton
    }
    
    fileprivate func updateImageTint() {
        imageView.tintColor = isHighlighted || isSelected ? nil : #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
    }
    
}
