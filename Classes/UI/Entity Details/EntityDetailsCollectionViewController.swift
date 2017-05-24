//
//  EntityDetailsCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


/// An abstract view controller for presenting entity details.
open class EntityDetailCollectionViewController: FormCollectionViewController {
    
    // MARK: Public properties
    
    /// The current entity to be presented.
    ///
    /// Subclasses should override this property to handle updating their
    /// content.
    open var entity: Entity?
    
    
    /// The "no content" title label.
    ///
    /// This label and it's associated subtitle label are hidden when the `hasContent`
    /// property is set to `true`.
    open var noContentTitleLabel: UILabel?
    
    
    /// The "no content" subtitle label.
    ///
    /// This label and it's associated title label are hidden when the `hasContent`
    /// property is set to `true`.
    open var noContentSubtitleLabel: UILabel?
    
    
    /// A boolean value indicating whether the view controller has content.
    /// 
    /// This updates the appearance of the "no content" labels on the view.
    /// The default is `true`, hiding the labels.
    open var hasContent: Bool = true {
        didSet {
            noContentView?.isHidden = hasContent
        }
    }
    
    private var noContentView: UIView?
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentLocaleDidChange), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        let noContentTitleLabel = UILabel(frame: .zero)
        noContentTitleLabel.numberOfLines = 0
        noContentTitleLabel.textAlignment = .center
        
        let noContentSubtitleLabel = UILabel(frame: .zero)
        noContentSubtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        noContentSubtitleLabel.textAlignment = .center
        noContentSubtitleLabel.numberOfLines = 0
        
        if #available(iOS 10, *) {
            noContentTitleLabel.adjustsFontForContentSizeCategory = true
            noContentSubtitleLabel.adjustsFontForContentSizeCategory = true
        }
        
        let stackView = UIStackView(arrangedSubviews: [noContentTitleLabel, noContentSubtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = hasContent
        stackView.spacing = 8.0
        stackView.axis = .vertical
        stackView.alignment = .center
        view.addSubview(stackView)
        
        self.noContentTitleLabel = noContentTitleLabel
        self.noContentSubtitleLabel = noContentSubtitleLabel
        self.noContentView = stackView
        
        updateNoContentTitleLabelFont()
        
        let readableContentGuide = view.readableContentGuide
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: readableContentGuide, attribute: .centerX),
            NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: readableContentGuide, attribute: .centerY),
            NSLayoutConstraint(item: stackView, attribute: .width,  relatedBy: .lessThanOrEqual, toItem: readableContentGuide, attribute: .width),
            NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: readableContentGuide, attribute: .height),
        ])
        
        super.viewDidLoad()
    }
    
    open override func applyCurrentTheme() {
        super.applyCurrentTheme()
        
        noContentTitleLabel?.textColor = primaryTextColor
        noContentSubtitleLabel?.textColor = secondaryTextColor
    }
    
    
    // MARK: - Change handlers
    
    open override func preferredContentSizeCategoryDidChange() {
        super.preferredContentSizeCategoryDidChange()
        updateNoContentTitleLabelFont()
    }
    
    open func currentLocaleDidChange() {
        collectionView?.reloadData()
    }
    
    
    // MARK: - Private methods
    
    private func updateNoContentTitleLabelFont() {
        var fontDescriptor: UIFontDescriptor
        if #available(iOS 10, *) {
            fontDescriptor = .preferredFontDescriptor(withTextStyle: .title3, compatibleWith: traitCollection)
        } else {
            fontDescriptor = .preferredFontDescriptor(withTextStyle: .title3)
        }
        
        if let adjusted = fontDescriptor.withSymbolicTraits(.traitBold) {
            fontDescriptor = adjusted
        }
        noContentTitleLabel?.font = UIFont(descriptor: fontDescriptor, size: 0.0)
    }
}
