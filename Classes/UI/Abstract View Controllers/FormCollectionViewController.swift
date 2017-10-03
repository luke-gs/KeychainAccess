//
//  FormCollectionViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 28/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var contentHeightContext = 1

fileprivate let tempID = "temp"

/// An abstract view controller for presenting a collection view based interface in
/// MPOL apps.
///
/// `FormCollectionViewController` differs from UITableViewController in several ways.
///
/// - First, the view of the view controller is a standard `UIView` instance, with a
/// UICollectionView instance positioned covering it as a subview, rather than as the
/// main view. This allows for subclasses to positon content visually around/above the
/// collection without convoluted hacks.
///
/// - Second, it manages its insets separately rather than allowing UIKit to
/// automatically adjust the insets. This works around multiple UIKit issues with
/// insets being incorrectly applied, especially in tab bar controllers.
///
/// - Third, it has default handling of MPOL theme-based changes, and has its own
/// `userInterfaceStyle` property. Where subclasses require to update for style
/// changes, they should override `collectionView(_:willDisplay:for:)` and other
/// analogous display preparation methods rather than requiring reloads. Other view
/// based changes can be completed with the open method `apply(_:)`.
open class FormCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CollectionViewDelegateFormLayout, PopoverViewController {
    
    // MARK: - Public properties
    
    open var formLayout: CollectionViewFormLayout!
    
    open private(set) var collectionView: UICollectionView?
    
    open private(set) var collectionViewInsetManager: ScrollViewInsetManager?
    
    open private(set) lazy var loadingManager: LoadingStateManager = LoadingStateManager()
    
    
    // Calculated heights
    
    /// A boolean value indicating whether the collection view should automatically calculate
    /// its `preferreContentSize`'s height property from the collection view's content height.
    ///
    /// The default is `false`.
    open var calculatesContentHeight = false {
        didSet {
            if calculatesContentHeight == oldValue { return }
            
            if calculatesContentHeight {
                collectionView?.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), options: [.new, .old], context: &contentHeightContext)
                updateCalculatedContentHeight()
            } else {
                collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &contentHeightContext)
            }
        }
    }
    
    @available(iOS, deprecated, renamed: "calculatesContentHeight")
    open var wantsCalculatedContentHeight: Bool {
        get { return calculatesContentHeight }
        set { calculatesContentHeight = newValue }
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
    
    /// The user interface style for the collection view.
    ///
    /// When set to `.current`, the theme autoupdates when the interface
    /// style changes.
    open var userInterfaceStyle: UserInterfaceStyle = .current {
        didSet {
            if userInterfaceStyle == oldValue { return }
            
            if userInterfaceStyle == .current {
                NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
            } else if oldValue == .current {
                NotificationCenter.default.removeObserver(self, name: .interfaceStyleDidChange, object: nil)
            }
            
            apply(ThemeManager.shared.theme(for: userInterfaceStyle))
        }
    }
    
    open var wantsTransparentBackground: Bool = false {
        didSet {
            if isViewLoaded {
                collectionView?.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
            }
        }
    }
    
    @NSCopying open private(set) var tintColor:            UIColor?
    
    @NSCopying open private(set) var backgroundColor:      UIColor?
    
    @NSCopying open private(set) var selectionColor:       UIColor?
    
    @NSCopying open private(set) var sectionTitleColor:    UIColor?
    
    @NSCopying open private(set) var primaryTextColor:     UIColor?
    
    @NSCopying open private(set) var secondaryTextColor:   UIColor?
    
    @NSCopying open private(set) var placeholderTextColor: UIColor?
    
    @NSCopying open private(set) var disclosureColor:      UIColor?
    
    @NSCopying open private(set) var separatorColor:       UIColor?
    
    @NSCopying open private(set) var validationErrorColor: UIColor?
    
    
    // MARK: - Subclass override points
    
    /// Allows subclasses to return a custom subclass of UICollectionView
    /// to use as the collection view.
    ///
    /// - Returns: The `UICollectionView` class to use for the main collection view.
    ///            The default returns `UICollectionView` itself.
    open func collectionViewClass() -> UICollectionView.Type {
        return UICollectionView.self
    }
    
    /// Allows subclasses to return a custom subclass of CollectionViewFormLayout
    open func collectionViewLayoutClass() -> CollectionViewFormLayout.Type {
        return CollectionViewFormLayout.self
    }

    // MARK: - Legacy support
    /// Additional content insets beyond the standard top and bottom layout guides.
    
    ///
    /// In iOS 11, you should use `additionalSafeAreaInsets` instead.
    @available(iOS, deprecated: 11.0, message: "Use `additionalSafeAreaInsets` instead.")
    open var legacy_additionalSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            if legacy_additionalSafeAreaInsets == oldValue || isViewLoaded == false { return }
            
            view.setNeedsLayout()
            
            if calculatesContentHeight {
                updateCalculatedContentHeight()
            }
        }
    }
    
    
    // MARK: - Initializers
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false // we manage this ourselves.
        
        if userInterfaceStyle == .current {
            NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
        }
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        if calculatesContentHeight == false { return }
        
        collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &contentHeightContext)
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let backgroundBounds = UIScreen.main.bounds
        
        formLayout = collectionViewLayoutClass().init()
        let collectionView = collectionViewClass().init(frame: backgroundBounds, collectionViewLayout: formLayout)
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = nil
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader,    withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: collectionElementKindGlobalFooter,    withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: tempID)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: tempID)
        
        if calculatesContentHeight {
            collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), options: [.old, .new], context: &contentHeightContext)
        }
        
        let backgroundView = UIView(frame: backgroundBounds)
        backgroundView.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
        backgroundView.addSubview(collectionView)
        
        self.collectionViewInsetManager = ScrollViewInsetManager(scrollView: collectionView)
        self.collectionView = collectionView
        self.view = backgroundView
        
        loadingManager.baseView = backgroundView
        loadingManager.contentView = collectionView

        // Layout collection view, using safe area layout guide on iOS 11
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor).withPriority(.almostRequired),
        ])
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11, *) {
            return
        }

        var insets = legacy_additionalSafeAreaInsets
        insets.top += topLayoutGuide.length
        insets.bottom += max(bottomLayoutGuide.length, statusTabBarInset)
        
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
    
    open func apply(_ theme: Theme) {
        tintColor            = theme.color(forKey: .tint)
        separatorColor       = theme.color(forKey: .separator)
        backgroundColor      = theme.color(forKey: .background)
        selectionColor       = theme.color(forKey: .cellSelection)
        primaryTextColor     = theme.color(forKey: .primaryText)
        secondaryTextColor   = theme.color(forKey: .secondaryText)
        placeholderTextColor = theme.color(forKey: .placeholderText)
        disclosureColor      = theme.color(forKey: .disclosure)
        validationErrorColor = theme.color(forKey: .validationError)
        
        loadingManager.noContentColor = secondaryTextColor ?? .gray
        
        setNeedsStatusBarAppearanceUpdate()
        
        guard let view = self.viewIfLoaded, let collectionView = self.collectionView else { return }
        
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
    
    @available(iOS, deprecated, renamed: "FormCollectionViewContoller.apply(_:)")
    open func applyCurrentTheme() {
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return ThemeManager.shared.theme(for: .current).statusBarStyle
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
        
        let primaryTextColor     = self.primaryTextColor     ?? .black
        let secondaryTextColor   = self.secondaryTextColor   ?? .darkGray
        let placeholderTextColor = self.placeholderTextColor ?? .gray
        
        if let formCell = cell as? CollectionViewFormCell {
            formCell.separatorColor = separatorColor
            formCell.validationColor = validationErrorColor
            
            if let accessory = formCell.accessoryView {
                func updateTintColor(for view: FormAccessoryView) {
                    switch view.style {
                    case .checkmark:
                        view.tintColor = nil
                    case .disclosure:
                        view.tintColor = disclosureColor
                    case .dropDown:
                        view.tintColor = primaryTextColor
                    }
                }
                
                switch accessory {
                case let formAccessory as FormAccessoryView:
                    updateTintColor(for: formAccessory)
                case let labeledAcccessory as LabeledAccessoryView:
                    labeledAcccessory.titleLabel.textColor = primaryTextColor
                    labeledAcccessory.subtitleLabel.textColor = secondaryTextColor
                    
                    if let formAccessory = labeledAcccessory.accessoryView as? FormAccessoryView {
                        updateTintColor(for: formAccessory)
                    }
                default:
                    break
                }
            }
        }
        
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
        case let textViewCell as CollectionViewFormTextViewCell:
            textViewCell.titleLabel.textColor       = secondaryTextColor
            textViewCell.textView.textColor         = primaryTextColor
            textViewCell.textView.placeholderLabel.textColor = placeholderTextColor
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
        if context == &contentHeightContext {
            if calculatesContentHeight == false { return }
            
            let old = change?[.oldKey] as? NSObject
            let new = change?[.newKey] as? NSObject
            
            if old != new {
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
        if calculatesContentHeight == false || isViewLoaded == false { return }
        
        let calculatedContentHeight = self.calculatedContentHeight()
        
        if preferredContentSize.height !=~ calculatedContentHeight {
            preferredContentSize.height = calculatedContentHeight
        }
    }
    
    
    /// Calculates the current preferred content size for the collection view.
    ///
    /// The default uses the current height of the collection view and additional content
    /// insets, clamped to the min and max values set on the class, and updates when the
    /// collection view's content height changes or the additional content insets change.
    open func calculatedContentHeight() -> CGFloat {
        var contentHeight = collectionView?.contentSize.height ?? 0.0

        if #available(iOS 11, *) {
            contentHeight += additionalSafeAreaInsets.top + additionalSafeAreaInsets.bottom
        } else {
            contentHeight += legacy_additionalSafeAreaInsets.top + legacy_additionalSafeAreaInsets.bottom
        }

        let minHeight = minimumCalculatedContentHeight
        let maxHeight = maximumCalculatedContentHeight
        
        return max(min(contentHeight, maxHeight), minHeight)
    }
    
    
    // MARK: - Private methods
    
    @objc private func interfaceStyleDidChange() {
        if userInterfaceStyle != .current { return }
        
        apply(ThemeManager.shared.theme(for: userInterfaceStyle))
    }
    
}

@available(iOS, introduced: 11.0)
extension FormCollectionViewController {

    open override var additionalSafeAreaInsets: UIEdgeInsets {
        didSet {
            if additionalSafeAreaInsets != oldValue && calculatesContentHeight {
                updateCalculatedContentHeight()
            }
        }
    }
    
}
