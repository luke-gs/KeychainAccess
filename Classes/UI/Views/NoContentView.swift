//
//  NoContentView.swift
//  MPOLKit
//
//  Created by Rod Brown on 26/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

private var contentContext = 1

@available(iOS, introduced: 10.0, obsoleted: 11.0)
private var hiddenContext = 2


/// A standard view for showing "No Content" within an MPOL interface.
///
/// `NoContentView is a UIStackView subclass designed for convenience with
/// the standard MPOL no content views correctly configured. The standard
/// views' `isHidden` property is managed by the class when the content
/// changes to or from nil. You can also adjust them manually where required.
///
/// Prior to iOS 11, spacers are used to insert custom space between the image
/// and title, and subtitle and button. On iOS 11 and later, this is managed
/// by the UIStackView custom spacing methods.
open class NoContentView: UIStackView {
    
    // MARK: - Public properties
    
    /// The standard image view.
    public let imageView = UIImageView(frame: .zero)
    
    /// The title label.
    public let titleLabel = UILabel(frame: .zero)
    
    /// The subtitle label.
    public let subtitleLabel = UILabel(frame: .zero)
    
    /// The action button.
    public let actionButton = RoundedRectButton(frame: .zero)
    
    /// The spacer used to separate the image and title label.
    ///
    /// This property is deprecated in iOS 11+. Please use UIStackView's 
    /// custom spacing methods.
    @available(iOS, introduced: 10.0, deprecated: 11.0, message: "Use custom sizes in iOS 11")
    public private(set) lazy var imageSpacer = SpacerView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 8.0))
    
    
    /// The spacer used to separate the subtitle label and button.
    ///
    /// This property is deprecated in iOS 11+. Please use UIStackView's
    /// custom spacing methods.
    @available(iOS, introduced: 10.0, deprecated: 11.0, message: "Use custom sizes in iOS 11")
    public private(set) lazy var buttonSpacer = SpacerView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 8.0))
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        imageView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
        actionButton.isHidden = true
        
        imageView.tintColor = .gray
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        if let adjusted = fontDescriptor.withSymbolicTraits(.traitBold) {
            fontDescriptor = adjusted
        }
        titleLabel.font = UIFont(descriptor: fontDescriptor, size: 0.0)
        
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        alignment = .center
        axis = .vertical
        spacing = 8.0
        
        addArrangedSubview(imageView)
        addArrangedSubview(titleLabel)
        addArrangedSubview(subtitleLabel)
        addArrangedSubview(actionButton)
        
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        titleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        subtitleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        subtitleLabel.addObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        actionButton.addObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.text), context: &contentContext)
        actionButton.addObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.attributedText), context: &contentContext)
        
        // TODO: Uncomment in iOS 11.0
        //if #available(iOS 11, *) {
        //    setCustomSpacing(8, after: imageView)
        //    setCustomSpacing(8, after: subtitleLabel)
        //    return
        //}
    
        imageSpacer.isHidden = true
        buttonSpacer.isHidden = true
        
        insertArrangedSubview(imageSpacer, at: 1)
        insertArrangedSubview(buttonSpacer, at: 4)
        
        imageView.addObserver(self, forKeyPath: #keyPath(UIImageView.isHidden), context: &hiddenContext)
        actionButton.addObserver(self, forKeyPath: #keyPath(UIButton.isHidden), context: &hiddenContext)
    }
    
    deinit {
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.image), context: &contentContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        titleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        subtitleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.text), context: &contentContext)
        subtitleLabel.removeObserver(self, forKeyPath: #keyPath(UILabel.attributedText), context: &contentContext)
        actionButton.removeObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.text), context: &contentContext)
        actionButton.removeObserver(self, forKeyPath: #keyPath(RoundedRectButton.titleLabel.attributedText), context: &contentContext)
        
        // TODO: Uncomment in iOS 11.0
        //if #available(iOS 11, *) { return }
        
        imageView.removeObserver(self, forKeyPath: #keyPath(UIImageView.isHidden), context: &hiddenContext)
        actionButton.removeObserver(self, forKeyPath: #keyPath(UIButton.isHidden), context: &hiddenContext)
    }
    
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &contentContext {
            switch object {
            case let imageView as UIImageView:
                imageView.isHidden = imageView.image == nil
            case let label as UILabel:
                label.isHidden = label.text?.isEmpty ?? true
            case let button as RoundedRectButton:
                button.isHidden = button.titleLabel?.text?.isEmpty ?? true
            default:
                break
            }
        } else if context == &hiddenContext {
            switch object {
            case let imageView as UIImageView:
                imageSpacer.isHidden = imageView.isHidden
            case let button as RoundedRectButton:
                buttonSpacer.isHidden = button.isHidden
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
