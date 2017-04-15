//
//  FormTableViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 13/4/17.
//
//

import UIKit

private var kvoContext = 1


open class FormTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PopoverViewController {
    
    open let tableViewStyle: UITableViewStyle
    
    open private(set) var tableView: UITableView?
    
    open private(set) var tableViewInsetManager: ScrollViewInsetManager?
    
    open var wantsTransparentBackground: Bool = false {
        didSet {
            tableView?.backgroundColor = wantsTransparentBackground ? .clear : backgroundColor
            tableView?.separatorStyle  = wantsSeparatorWhenTransparent || (wantsTransparentBackground == false) ? .singleLine : .none
        }
    }
    
    open var wantsSeparatorWhenTransparent: Bool {
        didSet {
            guard wantsSeparatorWhenTransparent != oldValue, wantsTransparentBackground,
                let tableView = self.tableView else { return }
            
            tableView.separatorStyle = wantsSeparatorWhenTransparent ? .singleLine : .none
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
    
    
    open var wantsCalculatedContentSize = true {
        didSet {
            if wantsCalculatedContentSize {
                updateContentSize()
            }
        }
    }
    
    open var minimumCalculatedContentHeight: CGFloat = 100.0
    
    open var maximumCalculatedContentHeight: CGFloat = .greatestFiniteMagnitude
    
    
    // MARK: - Initializers
    
    public init(style: UITableViewStyle) {
        tableViewStyle = style
        wantsSeparatorWhenTransparent = style == .grouped
        super.init(nibName: nil, bundle: nil)
        preferredContentSize.width = 320.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        
        if #available(iOS 10, *) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeCategoryDidChange), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        tableViewStyle = .plain
        wantsSeparatorWhenTransparent = false
        super.init(coder: aDecoder)
        preferredContentSize.width = 320.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        
        if #available(iOS 10, *) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeCategoryDidChange), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    deinit {
        tableView?.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: preferredContentSize.width, height: 400.0), style: tableViewStyle)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = wantsSeparatorWhenTransparent || (wantsTransparentBackground == false) ? .singleLine : .none
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.preservesSuperviewLayoutMargins = false
        tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
        
        updateTableBackgroundColor()
        
        let backgroundView = UIView(frame: tableView.frame)
        backgroundView.addSubview(tableView)
        
        self.tableViewInsetManager = ScrollViewInsetManager(scrollView: tableView)
        self.tableView = tableView
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
        tableViewInsetManager?.standardContentInset   = contentInsets
        tableViewInsetManager?.standardIndicatorInset = contentInsets
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 10, *) {
            if previousTraitCollection?.preferredContentSizeCategory ?? .unspecified != traitCollection.preferredContentSizeCategory {
                preferredContentSizeCategoryDidChange()
            }
        }
    }
    
    open func preferredContentSizeCategoryDidChange() {
        tableView?.reloadData()
    }
    
    // MARK: - Themes
    
    open func applyCurrentTheme() {
        let colors = Theme.current.colors
        
        separatorColor       = tableViewStyle == .grouped ? (colors[.GroupedTableSeparator]  ?? colors[.Separator])  : colors[.Separator]
        backgroundColor      = tableViewStyle == .grouped ? (colors[.GroupedTableBackground] ?? colors[.Background]) : colors[.Background]
        cellBackgroundColor  = tableViewStyle == .grouped ? colors[.GroupedTableCellBackground] : nil
        selectionColor       = colors[.CellSelection]
        primaryTextColor     = colors[.PrimaryText]
        secondaryTextColor   = colors[.SecondaryText]
        placeholderTextColor = colors[.PlaceholderText]
        
        setNeedsStatusBarAppearanceUpdate()
        
        guard isViewLoaded, let tableView = self.tableView else { return }
        
        updateTableBackgroundColor()
        tableView.separatorColor  = separatorColor
        
        for index in tableView.indexesForVisibleSectionHeaderViews {
            if let headerView = tableView.headerView(forSection: index) {
                self.tableView(tableView, willDisplayHeaderView: headerView, forSection: index)
            }
        }
        
        for index in tableView.indexesForVisibleSectionFooterViews {
            if let headerView = tableView.footerView(forSection: index) {
                self.tableView(tableView, willDisplayFooterView: headerView, forSection: index)
            }
        }
        
        // Don't use visibleCells for this - it will cause an inadvertant load of
        // cells if we are before the layout pass, commonly in viewDidLoad().
        for case let cell as UITableViewCell in tableView.subviews {
            if let indexPath = tableView.indexPath(for: cell) {
                self.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }
    }
    
    
    // MARK: - Status bar style
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
    open override var prefersStatusBarHidden : Bool {
        return false
    }
    
    
    // MARK: - UITableViewDataSource methods
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclasses must override this method, and must not call super.")
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
            if wantsCalculatedContentSize {
                updateContentSize()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateTableBackgroundColor() {
        guard let tableView = self.tableView else { return }
        
        let newColor: UIColor?
        if wantsTransparentBackground {
            if UIDevice.current.userInterfaceIdiom == .phone && Theme.current.isDark {
                newColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
            } else {
                newColor = tableViewStyle == .grouped ? nil : (cellBackgroundColor ?? .white)
            }
        } else {
            newColor = tableViewStyle == .grouped ? backgroundColor : (cellBackgroundColor ?? .white)
        }
        
        tableView.backgroundColor = newColor
    }
    
    internal func updateContentSize() {
        guard wantsCalculatedContentSize, let tableView = self.tableView else { return }
        
        let tableContentSize = tableView.contentSize
        
        let minHeight = minimumCalculatedContentHeight
        let maxHeight = maximumCalculatedContentHeight
        
        let clampedHeight = max(min(tableContentSize.height, maxHeight), minHeight)
        
        preferredContentSize = CGSize(width: tableContentSize.width, height: clampedHeight)
    }

}
