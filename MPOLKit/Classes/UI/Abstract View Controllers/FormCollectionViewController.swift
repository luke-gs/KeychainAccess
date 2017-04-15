//
//  FormCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


private let tempID = "temp"

open class FormCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CollectionViewDelegateFormLayout, PopoverViewController {
    
    
    // MARK: - Public properties
    
    open let formLayout: CollectionViewFormLayout
    
    open private(set) var collectionView: UICollectionView?
    
    open var wantsTransparentBackground: Bool = false {
        didSet {
            if isViewLoaded {
                collectionView?.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
            }
        }
    }
    
    @NSCopying open var tintColor:            UIColor?
    
    @NSCopying open var backgroundColor:      UIColor?
    
    @NSCopying open var selectionColor:       UIColor?
    
    @NSCopying open var sectionTitleColor:    UIColor?
    
    @NSCopying open var primaryTextColor:     UIColor?
    
    @NSCopying open var secondaryTextColor:   UIColor?
    
    @NSCopying open var placeholderTextColor: UIColor?
    
    @NSCopying open var separatorColor:       UIColor?
    
    
    
    
    // MARK: - Private properties
    
    private var collectionViewInsetManager: ScrollViewInsetManager?
    
    
    // MARK: - Initializers
    
    public init() {
        formLayout = CollectionViewFormLayout()
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false // we manage this ourselves.
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        
        if #available(iOS 10, *) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeCategoryDidChange), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let backgroundBounds = UIScreen.main.bounds
        
        let collectionView = UICollectionView(frame: backgroundBounds, collectionViewLayout: formLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = nil
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader,    withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: collectionElementKindGlobalFooter,    withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: tempID)
        
        let backgroundView = UIView(frame: backgroundBounds)
        backgroundView.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
        backgroundView.addSubview(collectionView)
        
        self.collectionViewInsetManager = ScrollViewInsetManager(scrollView: collectionView)
        self.collectionView = collectionView
        self.view = backgroundView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        applyCurrentTheme()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topLayoutPosition:    CGFloat
        let bottomLayoutPosition: CGFloat
        
        let view = self.view!
        let screenBounds = (view.window?.screen ?? .main).bounds
        
        if view.convert(view.bounds, to: nil).intersects(screenBounds) {
            // Onscreen.
            topLayoutPosition    = max(view.convert(CGPoint(x: 0.0, y: topLayoutGuide.length), from: nil).y, 0.0)
            bottomLayoutPosition = max(screenBounds.height - view.convert(CGPoint(x: 0.0, y: screenBounds.height - bottomLayoutGuide.length), from: nil).y, 0.0)
        } else {
            // Not onscreen.
            topLayoutPosition    = topLayoutGuide.length
            bottomLayoutPosition = bottomLayoutGuide.length
        }
        
        let contentInsets = UIEdgeInsets(top: topLayoutPosition, left: 0.0, bottom: bottomLayoutPosition, right: 0.0)
        collectionViewInsetManager?.standardContentInset    = contentInsets
        collectionViewInsetManager?.standardIndicatorInset  = contentInsets
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 10, *) {
            if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
                preferredContentSizeCategoryDidChange()
            }
        }
    }
    
    open func preferredContentSizeCategoryDidChange() {
        if isViewLoaded { formLayout.invalidateLayout() }
    }
    
    
    // MARK: - Themes
    
    open func applyCurrentTheme() {
        let colors = Theme.current.colors
        
        separatorColor       = colors[.Separator]
        backgroundColor      = colors[.Background]
        selectionColor       = colors[.CellSelection]
        primaryTextColor     = colors[.PrimaryText]
        secondaryTextColor   = colors[.SecondaryText]
        placeholderTextColor = colors[.PlaceholderText]
        
        setNeedsStatusBarAppearanceUpdate()
        
        if isViewLoaded,
            let view = self.view,
            let collectionView = self.collectionView {
            view.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
            
            for cell in collectionView.visibleCells {
                if let indexPath = collectionView.indexPath(for: cell) {
                    self.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
                }
            }
            
            if let globalHeader = collectionView.visibleSupplementaryViews(ofKind: collectionElementKindGlobalHeader).first {
                self.collectionView(collectionView, willDisplaySupplementaryView: globalHeader, forElementKind: collectionElementKindGlobalHeader, at: IndexPath(index: 0))
            }
            if let globalFooter = collectionView.visibleSupplementaryViews(ofKind: collectionElementKindGlobalFooter).first {
                self.collectionView(collectionView, willDisplaySupplementaryView: globalFooter, forElementKind: collectionElementKindGlobalFooter, at: IndexPath(index: 0))
            }
            
            let sectionHeaderIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
            for indexPath in sectionHeaderIndexPaths {
                if let headerView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) {
                    self.collectionView(collectionView, willDisplaySupplementaryView: headerView, forElementKind: UICollectionElementKindSectionHeader, at: indexPath)
                }
            }
            
            let sectionFooterIndexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionFooter)
            for indexPath in sectionFooterIndexPaths {
                if let footerView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: indexPath) {
                    self.collectionView(collectionView, willDisplaySupplementaryView: footerView, forElementKind: UICollectionElementKindSectionFooter, at: indexPath)
                }
            }
        }
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Subclasses must override this method, and must not call super.")
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let defaultView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: tempID, for: indexPath)
        defaultView.isUserInteractionEnabled = false
        return defaultView
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        (cell as? CollectionViewFormCell)?.separatorColor = separatorColor
        
        let primaryTextColor     = self.primaryTextColor     ?? .black
        let secondaryTextColor   = self.secondaryTextColor   ?? .darkGray
        let placeholderTextColor = self.placeholderTextColor ?? .gray
        
        switch cell {
        case let formCell as EntityCollectionViewCell:
            formCell.titleLabel.textColor    = primaryTextColor
            formCell.subtitleLabel.textColor = secondaryTextColor
            formCell.detailLabel.textColor   = secondaryTextColor
        case let selectionCell as CollectionViewFormOptionCell:
            selectionCell.titleLabel.textColor = primaryTextColor
        case let subtitleCell as CollectionViewFormSubtitleCell:
            if subtitleCell.emphasis == .title {
                subtitleCell.titleLabel.textColor    = primaryTextColor
                subtitleCell.subtitleLabel.textColor = secondaryTextColor
            } else {
                subtitleCell.titleLabel.textColor    = secondaryTextColor
                
                if subtitleCell.isEditableField {
                    subtitleCell.subtitleLabel.textColor = primaryTextColor
                    
                    guard let title = subtitleCell.titleLabel.text as NSString? else { return }
                    
                    let rangeOfStar = title.range(of: "*")
                    if rangeOfStar.location == NSNotFound { return }
                    
                    let titleString = NSMutableAttributedString(string: title as String)
                    titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
                    subtitleCell.titleLabel.attributedText = titleString
                } else {
                    subtitleCell.subtitleLabel.textColor = secondaryTextColor
                }
            }
        case let textFieldCell as CollectionViewFormTextFieldCell:
            textFieldCell.titleLabel.textColor = secondaryTextColor
            textFieldCell.textField.textColor  = primaryTextColor
            textFieldCell.textField.placeholderTextColor = placeholderTextColor
            
            guard let title = textFieldCell.titleLabel.text as NSString? else { return }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { return }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            textFieldCell.titleLabel.attributedText = titleString
        case let textViewCell as CollectionViewFormTextViewCell:
            textViewCell.titleLabel.textColor       = secondaryTextColor
            textViewCell.textView.textColor         = primaryTextColor
            textViewCell.textView.placeholderLabel.textColor = placeholderTextColor
            
            guard let title = textViewCell.titleLabel.text as NSString? else { return }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { return }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            textViewCell.titleLabel.attributedText = titleString
        default:
            break
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        switch view {
        case let headerView as CollectionViewFormExpandingHeaderView:
            headerView.tintColor = secondaryTextColor
        default:
            break
        }
    }
    
    
    // MARK: - CollectionViewDelegateMPOLLayout methods
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 0.0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return 0.0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 16.0)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        return sectionWidth
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return 39.0
    }
    
    
    // MARK: - Status bar overrides
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
    open override var prefersStatusBarHidden : Bool {
        return false
    }
}
