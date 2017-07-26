//
//  FormCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

fileprivate let tempID = "temp"

open class FormCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CollectionViewDelegateFormLayout, PopoverViewController {
    
    
    // MARK: - Public properties
    
    open let formLayout: CollectionViewFormLayout
    
    open private(set) var collectionView: UICollectionView?
    
    open private(set) var collectionViewInsetManager: ScrollViewInsetManager?
    
    open private(set) lazy var loadingManager: LoadingStateManager = LoadingStateManager()
    
    
    /// A boolean value indicating whether the collection view should automatically calculate
    /// its `preferreContentSize`'s height property from the collection view's content height.
    ///
    /// The default is `false`.
    open var wantsCalculatedContentHeight = false {
        didSet {
            if wantsCalculatedContentHeight == oldValue { return }
            
            if wantsCalculatedContentHeight {
                collectionView?.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
                updateCalculatedContentHeight()
            } else {
                collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
            }
        }
    }
    
    
    /// The minimum allowed calculated content height. The default is `100.0`.
    open var minimumCalculatedContentHeight: CGFloat = 100.0 {
        didSet {
            if isViewLoaded && minimumCalculatedContentHeight >~ preferredContentSize.height {
                updateCalculatedContentHeight()
            }
        }
    }
    
    
    /// The maximum allowed calculated content height. The default is `.infinity`,
    /// meaning there is no restriction on the content height.
    open var maximumCalculatedContentHeight: CGFloat = .infinity {
        didSet {
            if isViewLoaded && maximumCalculatedContentHeight < preferredContentSize.height {
                updateCalculatedContentHeight()
            }
        }
    }
    
    // Appearance properties
    
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
    
    @NSCopying open var validationErrorColor: UIColor?
    
    
    // MARK: - Initializers
    
    public init() {
        formLayout = CollectionViewFormLayout()
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false // we manage this ourselves.
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        if wantsCalculatedContentHeight {
            collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
        }
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
        
        if wantsCalculatedContentHeight {
            collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
        }
        
        let backgroundView = UIView(frame: backgroundBounds)
        backgroundView.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
        backgroundView.addSubview(collectionView)
        
        self.collectionViewInsetManager = ScrollViewInsetManager(scrollView: collectionView)
        self.collectionView = collectionView
        self.view = backgroundView
        
        loadingManager.baseView = backgroundView
        loadingManager.contentView = collectionView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        applyCurrentTheme()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        loadingManager.contentInsets = insets
        collectionViewInsetManager?.standardContentInset   = insets
        collectionViewInsetManager?.standardIndicatorInset = insets
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            preferredContentSizeCategoryDidChange()
        }
    }
    
    open func preferredContentSizeCategoryDidChange() {
        if isViewLoaded { formLayout.invalidateLayout() }
    }
    
    
    // MARK: - Themes
    
    open func applyCurrentTheme() {
        let colors = Theme.current.colors
        
        tintColor            = colors[.Tint]
        separatorColor       = colors[.Separator]
        backgroundColor      = colors[.Background]
        selectionColor       = colors[.CellSelection]
        primaryTextColor     = colors[.PrimaryText]
        secondaryTextColor   = colors[.SecondaryText]
        placeholderTextColor = colors[.PlaceholderText]
        validationErrorColor = colors[.ValidationError]
        
        loadingManager.noContentColor = secondaryTextColor ?? .gray
        
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
                self.collectionView(collectionView, willDisplaySupplementaryView: globalHeader, forElementKind: collectionElementKindGlobalHeader, at: IndexPath(item: 0, section: 0))
            }
            if let globalFooter = collectionView.visibleSupplementaryViews(ofKind: collectionElementKindGlobalFooter).first {
                self.collectionView(collectionView, willDisplaySupplementaryView: globalFooter, forElementKind: collectionElementKindGlobalFooter, at: IndexPath(item: 0, section: 0))
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
        MPLRequiresConcreteImplementation()
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let defaultView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: tempID, for: indexPath)
        defaultView.isUserInteractionEnabled = false
        return defaultView
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let formCell = cell as? CollectionViewFormCell {
            formCell.separatorColor = separatorColor
            formCell.validationColor = validationErrorColor
        }
        
        let primaryTextColor     = self.primaryTextColor     ?? .black
        let secondaryTextColor   = self.secondaryTextColor   ?? .darkGray
        let placeholderTextColor = self.placeholderTextColor ?? .gray
        
        switch cell {
        case let formCell as EntityCollectionViewCell:
            formCell.titleLabel.textColor    = primaryTextColor
            formCell.subtitleLabel.textColor = secondaryTextColor
            formCell.detailLabel.textColor   = secondaryTextColor
        case let listCell as EntityListCollectionViewCell:
            listCell.titleLabel.textColor = primaryTextColor
            listCell.subtitleLabel.textColor = secondaryTextColor
        case let selectionCell as CollectionViewFormOptionCell:
            selectionCell.titleLabel.textColor = primaryTextColor
        case let valueFieldCell as CollectionViewFormValueFieldCell:
            valueFieldCell.valueLabel.textColor = valueFieldCell.isEditable ? primaryTextColor : secondaryTextColor
            valueFieldCell.titleLabel.textColor = secondaryTextColor
            valueFieldCell.placeholderLabel.textColor = placeholderTextColor
            
            guard let title = valueFieldCell.titleLabel.text as NSString? else { break }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { break }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            valueFieldCell.titleLabel.attributedText = titleString
        case let subtitleCell as CollectionViewFormSubtitleCell:
            subtitleCell.titleLabel.textColor    = primaryTextColor
            subtitleCell.subtitleLabel.textColor = secondaryTextColor
        case let detailCell as CollectionViewFormDetailCell:
            detailCell.titleLabel.textColor    = primaryTextColor
            detailCell.subtitleLabel.textColor = secondaryTextColor
            detailCell.detailLabel.textColor   = primaryTextColor
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
        case let headerView as CollectionViewFormHeaderView:
            headerView.tintColor = secondaryTextColor
            headerView.separatorColor = separatorColor
        default:
            break
        }
    }
    
    
    // MARK: - CollectionViewDelegateMPOLLayout methods
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 16.0)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return 39.0
    }
    
    
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if wantsCalculatedContentHeight {
                updateCalculatedContentHeight()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Content height methods
    
    
    /// Updates the calculated content height of the collection view.
    ///
    /// Subclasses should not need to override this method, but
    /// should call this method when their calculated content size changes.
    open func updateCalculatedContentHeight() {
        if wantsCalculatedContentHeight == false || isViewLoaded == false { return }
        
        let calculatedContentHeight = self.calculatedContentHeight()
        
        if preferredContentSize.height !=~ calculatedContentHeight {
            preferredContentSize.height = calculatedContentHeight
        }
    }
    
    
    /// Calculates the current preferred content size for the collection view.
    ///
    /// The default uses the current height of the collection view, clamped to the min
    /// and max values set on the class, and updates when the collection view's content
    /// height changes.
    ///
    /// Subclasses should override this method to adjust for any additional content
    /// e.g. search bars and other adornments, but should observe the min and max
    /// values set.
    open func calculatedContentHeight() -> CGFloat {
        let collectionContentHeight = (collectionView?.contentSize.height ?? 0.0)
        
        let minHeight = minimumCalculatedContentHeight
        let maxHeight = maximumCalculatedContentHeight
        
        return max(min(collectionContentHeight, maxHeight), minHeight)
    }
    
    
    // MARK: - Status bar overrides
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
}
