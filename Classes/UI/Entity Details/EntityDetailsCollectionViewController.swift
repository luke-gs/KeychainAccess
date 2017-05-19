//
//  EntityDetailsCollectionViewController.swift
//  Pods
//
//  Created by Rod Brown on 19/5/17.
//
//

import UIKit

open class EntityDetailCollectionViewController: FormCollectionViewController {
    
    open var entity: Entity?
    
    open var noContentTitleLabel: UILabel?
    
    open var noContentSubtitleLabel: UILabel?
    
    public var hasContent: Bool = true {
        didSet {
            noContentView?.isHidden = hasContent
        }
    }
    
    private var noContentView: UIView?
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentLocaleDidChange), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    
    
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
            NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: readableContentGuide, attribute: .width),
            NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: readableContentGuide, attribute: .height),
        ])
        
        super.viewDidLoad()
    }
    
    open override func applyCurrentTheme() {
        super.applyCurrentTheme()
        
        noContentTitleLabel?.textColor = primaryTextColor
        noContentSubtitleLabel?.textColor = secondaryTextColor
    }
    
    
    open override func preferredContentSizeCategoryDidChange() {
        super.preferredContentSizeCategoryDidChange()
        updateNoContentTitleLabelFont()
    }
    
    open func currentLocaleDidChange() {
        collectionView?.reloadData()
    }
    
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
