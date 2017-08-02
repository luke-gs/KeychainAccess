//
//  FormTableViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 13/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var kvoContext = 1

/// An abstract view controller for presenting a table view based interface in
/// MPOL apps.
///
/// `FormTableViewController` differs from UITableViewController in several ways.
///
/// - First, the view of the view controller is a standard `UIView` instance, with a
/// UITableView instance positioned covering it as a subview, rather than as the
/// main view. This allows for subclasses to positon content visually above the
/// table without convoluted hacks.
///
/// - Second, it manages its insets separately rather than allowing UIKit to
/// automatically adjust the insets. This works around multiple UIKit issues with
/// insets being incorrectly applied, especially in tab bar controllers.
///
/// - Third, it has default handling of MPOL theme-based changes. Where subclasses
/// require to update for theme changes, they should override
/// `tableView(_:willDisplay:for:)` and other analogous display preparation methods
/// rathern than requiring reloads. Other view based changes can be completed with
/// the open method `applyCurrentTheme()`.
open class FormTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopoverViewController {
    
    // MARK: - Public properties
    
    /// The style for the table view.
    open let tableViewStyle: UITableViewStyle
    
    
    /// The table view for the controller. This is lazily loaded with the view.
    open private(set) var tableView: UITableView?
    
    
    /// The table view's inset manager. This is lazily loaded with the view.
    open private(set) var tableViewInsetManager: ScrollViewInsetManager?
    
    
    /// The loading manager.
    open private(set) lazy var loadingManager: LoadingStateManager = LoadingStateManager()
    
    
    /// Additional content insets beyond the standard top and bottom layout guides.
    ///
    /// In iOS 11, this value maps directly to the `additionalSafeAreaInsets`, but
    /// this property is backwards compatible down to iOS 10. You should use this
    /// property regardless at this time, as we do some extra work.
    ///
    /// Internal note: When we drop iOS 10 support some time in the future, all
    /// surrounding logic should transition to an override of
    /// `additionalSafeAreaInsets` itself. Currently we can't do that because
    /// limited-availability-overriding is blocked in Swift. This should then
    /// be marked as deprecated, and simply call the getters and setters on that
    /// property.
    open var additionalContentInsets: UIEdgeInsets {
        get {
            // TODO: Uncomment in iOS 11
//            if #available(iOS 11, *) {
//                return additionalSafeAreaInsets
//            } else {
                return _additionalContentInsets
//            }
        }
        set {
            if newValue == additionalContentInsets { return }
            
            // TODO: Uncomment in iOS 11
//            if #available(iOS 11, *) {
//                additionalSafeAreaInsets = newValue
//            } else {
                _additionalContentInsets = newValue
                viewIfLoaded?.setNeedsLayout()
//            }
            if isViewLoaded && wantsCalculatedContentHeight {
                updateCalculatedContentHeight()
            }
        }
    }
    
    
    
    /// A boolean value indicating whether the table background should be transparent.
    ///
    /// The default is `false`.
    open var wantsTransparentBackground: Bool = false {
        didSet {
            if isViewLoaded && wantsTransparentBackground != oldValue {
                updateTableBackgroundColor()
            }
        }
    }
    
    /// A boolean value indicating if the controller clears the selection when the
    /// table appears.
    /// 
    /// The default value of this property is true. When true, the table view controller
    /// clears the table’s current selection when it receives a viewWillAppear(_:)
    /// message. Setting this property to false preserves the selection.
    open var clearsSelectionOnViewWillAppear: Bool = true
    
    
    /// A boolean value indicating whether the table view should display with separators
    /// when with a transparent background.
    ///
    /// Some MPOL views require separators to be hidden when appearing transparently,
    /// for example in a popover.
    ///
    /// The default is `false` on plain style table views, and `true` in the grouped style.
    open var wantsSeparatorWhenTransparent: Bool {
        didSet {
            guard wantsSeparatorWhenTransparent != oldValue, wantsTransparentBackground,
                let tableView = self.tableView else { return }
            
            tableView.separatorStyle = wantsSeparatorWhenTransparent ? .singleLine : .none
        }
    }
    
    
    /// A boolean value indicating whether the table view should automatically calculate
    /// its `preferreContentSize`'s height property from the table view's content height.
    ///
    /// The default is `false`.
    open var wantsCalculatedContentHeight = false {
        didSet {
            if wantsCalculatedContentHeight == oldValue { return }
            
            if wantsCalculatedContentHeight {
                tableView?.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
                updateCalculatedContentHeight()
            } else {
                tableView?.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
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
    
    @NSCopying open private(set) var tintColor:            UIColor?
    
    @NSCopying open private(set) var backgroundColor:      UIColor?
    
    @NSCopying open private(set) var cellBackgroundColor:  UIColor?
    
    @NSCopying open private(set) var selectionColor:       UIColor?
    
    @NSCopying open private(set) var sectionTitleColor:    UIColor?
    
    @NSCopying open private(set) var primaryTextColor:     UIColor?
    
    @NSCopying open private(set) var secondaryTextColor:   UIColor?
    
    @NSCopying open private(set) var placeholderTextColor: UIColor?
    
    @NSCopying open private(set) var separatorColor:       UIColor?
    
    
    // MARK: - Subclass override points
    
    /// Allows subclasses to return a custom subclass of `UITableView`
    /// to use as the table view.
    ///
    /// - Returns: The `UITableView` class to use for the main table view.
    ///            The default returns `UICollectionView` itself.
    open func tableViewClass() -> UITableView.Type {
        return UITableView.self
    }
    
    
    // MARK: - Private properties
    
    @available(iOS, deprecated: 11.0, renamed: "additionalSafeAreaInsets", message: "Use additionalSafeAreaInsets in iOS 11.")
    private var _additionalContentInsets: UIEdgeInsets = .zero {
        didSet {
            if _additionalContentInsets != oldValue {
                viewIfLoaded?.setNeedsLayout()
            }
        }
    }
    
    // MARK: - Initializers
    
    public init(style: UITableViewStyle) {
        tableViewStyle = style
        wantsSeparatorWhenTransparent = style == .grouped
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        tableViewStyle = .plain
        wantsSeparatorWhenTransparent = false
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
    }
    
    deinit {
        if wantsCalculatedContentHeight {
            tableView?.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
        }
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let tableView = tableViewClass().init(frame: CGRect(x: 0.0, y: 0.0, width: preferredContentSize.width, height: 400.0), style: tableViewStyle)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = wantsSeparatorWhenTransparent || (wantsTransparentBackground == false) ? .singleLine : .none
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.preservesSuperviewLayoutMargins = false
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
        
        if wantsCalculatedContentHeight {
            tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
        }
        
        let backgroundView = UIView(frame: tableView.frame)
        backgroundView.addSubview(tableView)
        
        self.tableViewInsetManager = ScrollViewInsetManager(scrollView: tableView)
        self.tableView = tableView
        self.view = backgroundView
        
        loadingManager.baseView = backgroundView
        loadingManager.contentView = tableView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        applyCurrentTheme()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var insets = _additionalContentInsets
        insets.top += topLayoutGuide.length
        insets.bottom += max(bottomLayoutGuide.length, statusTabBarInset)
        
        loadingManager.contentInsets = insets
        tableViewInsetManager?.standardContentInset   = insets
        tableViewInsetManager?.standardIndicatorInset = insets
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if clearsSelectionOnViewWillAppear,
            let tableView = self.tableView,
            let selectedIndexPaths = tableView.indexPathsForVisibleRows {
            
            for indexPath in selectedIndexPaths {
                tableView.deselectRow(at: indexPath, animated: animated)
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.preferredContentSizeCategory ?? .unspecified != traitCollection.preferredContentSizeCategory {
            preferredContentSizeCategoryDidChange()
        }
    }
    
    open func preferredContentSizeCategoryDidChange() {
        if isViewLoaded {
            tableView?.reloadData()
        }
    }
    
    // MARK: - Themes
    
    open func applyCurrentTheme() {
        let colors = Theme.current.colors
        
        tintColor            = colors[.Tint]
        separatorColor       = tableViewStyle == .grouped ? (colors[.GroupedTableSeparator]  ?? colors[.Separator])  : colors[.Separator]
        backgroundColor      = tableViewStyle == .grouped ? (colors[.GroupedTableBackground] ?? colors[.Background]) : colors[.Background]
        cellBackgroundColor  = tableViewStyle == .grouped ? colors[.GroupedTableCellBackground] : nil
        selectionColor       = colors[.CellSelection]
        primaryTextColor     = colors[.PrimaryText]
        secondaryTextColor   = colors[.SecondaryText]
        placeholderTextColor = colors[.PlaceholderText]
        
        loadingManager.noContentColor = secondaryTextColor ?? .gray
        
        setNeedsStatusBarAppearanceUpdate()
        
        guard let tableView = self.tableView else { return }
        
        updateTableBackgroundColor()
        tableView.separatorColor  = separatorColor
        
        for index in tableView.indexesForVisibleSectionHeaders {
            if let headerView = tableView.headerView(forSection: index) {
                self.tableView(tableView, willDisplayHeaderView: headerView, forSection: index)
            }
        }
        
        for index in tableView.indexesForVisibleSectionFooters {
            if let headerView = tableView.footerView(forSection: index) {
                self.tableView(tableView, willDisplayFooterView: headerView, forSection: index)
            }
        }
        
        // Don't use visibleCells for this - it will cause an inadvertant load of
        // cells if we are before the layout pass, commonly in viewDidLoad().
        for cell in tableView.allSubviews(of: UITableViewCell.self) {
            if let indexPath = tableView.indexPath(for: cell) {
                self.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }
    }
    
    
    // MARK: - Status bar style
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
    
    // MARK: - UITableViewDataSource methods
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        MPLRequiresConcreteImplementation()
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerLabel = (view as? UITableViewHeaderFooterView)?.textLabel {
            headerLabel.font = .systemFont(ofSize: 13.0, weight: UIFontWeightSemibold)
            headerLabel.textColor = .gray
        }
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerLabel = (view as? UITableViewHeaderFooterView)?.textLabel {
            headerLabel.font = .systemFont(ofSize: 13.0, weight: UIFontWeightSemibold)
            headerLabel.textColor = .gray
        }
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = cellBackgroundColor
        cell.selectedBackgroundView?.backgroundColor = selectionColor
        
        let primaryTextColor     = self.primaryTextColor     ?? .black
        let secondaryTextColor   = self.secondaryTextColor   ?? .darkGray
        let placeholderTextColor = self.placeholderTextColor ?? .gray
        
        switch cell {
        case let textViewCell as TableViewFormTextViewCell:
            textViewCell.titleLabel.textColor       = secondaryTextColor
            textViewCell.textView.textColor         = primaryTextColor
            textViewCell.textView.placeholderLabel.textColor = placeholderTextColor
            
            guard let title = textViewCell.titleLabel.text as NSString? else { return }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { return }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            textViewCell.titleLabel.attributedText = titleString
        case let textFieldCell as TableViewFormTextFieldCell:
            textFieldCell.titleLabel.textColor = secondaryTextColor
            textFieldCell.textField.textColor  = primaryTextColor
            textFieldCell.textField.placeholderTextColor = placeholderTextColor
            
            guard let title = textFieldCell.titleLabel.text as NSString? else { return }
            
            let rangeOfStar = title.range(of: "*")
            if rangeOfStar.location == NSNotFound { return }
            
            let titleString = NSMutableAttributedString(string: title as String)
            titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
            textFieldCell.titleLabel.attributedText = titleString
        case let subtitleCell as TableViewFormSubtitleCell:
            if subtitleCell.emphasis == .title {
                subtitleCell.textLabel.textColor    = primaryTextColor
                subtitleCell.detailTextLabel.textColor = secondaryTextColor
            } else {
                subtitleCell.textLabel.textColor    = secondaryTextColor
                
//                if subtitleCell.isEditableField {
//                    subtitleCell.subtitleLabel.textColor = primaryTextColor
//                    
//                    guard let title = subtitleCell.titleLabel.text as NSString? else { return }
//                    
//                    let rangeOfStar = title.range(of: "*")
//                    if rangeOfStar.location == NSNotFound { return }
//                    
//                    let titleString = NSMutableAttributedString(string: title as String)
//                    titleString.setAttributes([NSForegroundColorAttributeName: UIColor.red], range: rangeOfStar)
//                    subtitleCell.titleLabel.attributedText = titleString
//                } else {
                    subtitleCell.detailTextLabel.textColor = secondaryTextColor
//                }
            }
        default:
            cell.textLabel?.textColor = primaryTextColor
            cell.detailTextLabel?.textColor = secondaryTextColor
        }
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
    
    
    /// Updates the calculated content height of the table.
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
    
    /// Calculates the current preferred content size for the table view.
    ///
    /// The default uses the current height of the table view and additional content
    /// insets, clamped to the min and max values set on the class, and updates when the
    /// table view's content height changes or the additional content insets change.
    open func calculatedContentHeight() -> CGFloat {
        let tableContentHeight = (tableView?.contentSize.height ?? 0.0) + additionalContentInsets.top + additionalContentInsets.bottom
        
        let minHeight = minimumCalculatedContentHeight
        let maxHeight = maximumCalculatedContentHeight
        
        return max(min(tableContentHeight, maxHeight), minHeight)
    }
    
    
    // MARK: - Private methods
    
    private func updateTableBackgroundColor() {
        guard let tableView = self.tableView else { return }
        
        let newColor: UIColor?
        if wantsTransparentBackground {
            if UIDevice.current.userInterfaceIdiom == .phone && Theme.current.isDark {
                newColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
            } else {
                newColor = .clear
            }
        } else {
            newColor = tableViewStyle == .grouped ? backgroundColor : (cellBackgroundColor ?? .white)
        }
        
        tableView.backgroundColor = newColor
        tableView.separatorStyle  = wantsSeparatorWhenTransparent || (wantsTransparentBackground == false) ? .singleLine : .none
    }

}



