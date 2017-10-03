//
//  RegularSidebarViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 11/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var sidebarItemContext = 0
fileprivate let sidebarKeys = [#keyPath(SidebarItem.isEnabled),
                               #keyPath(SidebarItem.image),
                               #keyPath(SidebarItem.selectedImage),
                               #keyPath(SidebarItem.title),
                               #keyPath(SidebarItem.count),
                               #keyPath(SidebarItem.alertColor),
                               #keyPath(SidebarItem.color),
                               #keyPath(SidebarItem.selectedColor)]


/// Regular size-class version of sidebar used for displaying navigation items in a split view controller
/// Items displayed in a vertical table
open class RegularSidebarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SourceBarDelegate {
    
    // MARK: - Public properties
    
    /// The current items available to display.
    public var items: [SidebarItem] = [] {
        didSet {
            let items = self.items
            
            for item in oldValue where items.contains(item) == false {
                sidebarKeys.forEach { item.removeObserver(self, forKeyPath: $0, context: &sidebarItemContext) }
            }
            
            for item in items where oldValue.contains(item) == false {
                sidebarKeys.forEach { item.addObserver(self, forKeyPath: $0, context: &sidebarItemContext) }
            }
            
            sidebarTableView?.reloadData()
            
            if let selectedItem = self.selectedItem, items.contains(selectedItem) == false {
                self.selectedItem = nil
            }
        }
    }
    
    
    /// The selected item.
    ///
    /// If `clearsSelectionOnViewWillAppear` is true, this property is set to nil
    /// when it receives a viewWillAppear(_:) message.
    public var selectedItem: SidebarItem? {
        didSet { updateSelection() }
    }
    
    
    /// The current sources available to display.
    ///
    /// When empty, the source list is hidden.
    public var sourceItems: [SourceItem] = [] {
        didSet {
            viewIfLoaded?.setNeedsLayout()
            sourceBar?.items = sourceItems
            
            if let selectedSourceIndex = selectedSourceIndex,
                selectedSourceIndex >= sourceItems.count {
                self.selectedSourceIndex = nil
            } else {
                sourceBar?.selectedIndex = selectedSourceIndex
            }
        }
    }
    
    
    /// The selected source index.
    public var selectedSourceIndex: Int? = nil {
        didSet {
            if let selectedSourceIndex = selectedSourceIndex {
                precondition(selectedSourceIndex < sourceItems.count)
            }
            sourceBar?.selectedIndex = selectedSourceIndex
        }
    }
    
    /// Whether source bar should be hidden
    public var hideSourceBar: Bool = false {
        didSet {
            // Make table view full width and hide source bar
            tableViewFullWidth?.isActive = hideSourceBar
            sourceBar?.isHidden = hideSourceBar
        }
    }

    /// The table view for sidebar items.
    /// 
    /// This table view fills the sidebar, trailing the source bar if it appears.
    public private(set) var sidebarTableView: UITableView?
    
    
    /// The header view for the sidebar. This view is sized with auto layout much like
    /// autosizing table view cells.
    ///
    /// It is highly recommended that you use this property rather than the table view's
    /// `tableHeaderView` property.
    open var headerView: UIView? {
        didSet {
            if headerView == oldValue { return }
            
            guard let sidebarTableView = sidebarTableView else { return }
            
            sidebarTableView.estimatedSectionHeaderHeight = headerView == nil ? 0.0 : 30.0
            sidebarTableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
    
    
    /// A Boolean value indicating whether the sidebar clears the selection when the view appears.
    ///
    /// The default value of this property is false. If true, the view controller clears the
    /// selectedItem when it receives a viewWillAppear(_:) message.
    open var clearsSelectionOnViewWillAppear: Bool = false
    
    
    /// The delegate for the sidebar.
    open weak var delegate: SidebarDelegate? = nil
    
    
    // MARK: - Private properties
    
    private var sourceBar: SourceBar?
    
    private var sourceInsetManager: ScrollViewInsetManager?
    
    private var sidebarInsetManager: ScrollViewInsetManager?

    /// Constraint for making table full width, hiding source bar
    private var tableViewFullWidth: NSLayoutConstraint?
    
    // MARK: - Initializer
    
    deinit {
        items.forEach { item in
            sidebarKeys.forEach {
                item.removeObserver(self, forKeyPath: $0, context: &sidebarItemContext)
            }
        }
    }
    
    
    // MARK: - View lifecycle
    
    open override func loadView() {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let sidebarColor = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
        
        let sourceBackground = GradientView(frame: .zero)
        sourceBackground.gradientColors = [#colorLiteral(red: 0.05098039216, green: 0.05490196078, blue: 0.06274509804, alpha: 1), sidebarColor]
        
        let sourceBar = SourceBar(frame: .zero)
        sourceBar.translatesAutoresizingMaskIntoConstraints = false
        sourceBar.backgroundView = sourceBackground
        sourceBar.sourceBarDelegate = self
        sourceBar.items = sourceItems
        sourceBar.selectedIndex = selectedSourceIndex
        view.addSubview(sourceBar)
        
        let sidebarTableView = UITableView(frame: .zero, style: .grouped)
        sidebarTableView.translatesAutoresizingMaskIntoConstraints = false
        sidebarTableView.backgroundColor    = sidebarColor
        sidebarTableView.dataSource         = self
        sidebarTableView.delegate           = self
        sidebarTableView.separatorStyle     = .none
        sidebarTableView.estimatedRowHeight = 50.0
        sidebarTableView.indicatorStyle     = .white
        sidebarTableView.tableHeaderView    = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 10.0))
        sidebarTableView.register(RegularSidebarTableViewCell.self)
        sidebarTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        sidebarTableView.estimatedSectionHeaderHeight = headerView == nil ? 0.0 : 30.0
        view.addSubview(sidebarTableView)
        
        self.view             = view
        self.sourceBar        = sourceBar
        self.sidebarTableView = sidebarTableView
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: sourceBar, attribute: .top,     relatedBy: .equal, toItem: view, attribute: .top),
            NSLayoutConstraint(item: sourceBar, attribute: .bottom,  relatedBy: .equal, toItem: view, attribute: .bottom),
            NSLayoutConstraint(item: sourceBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading),
            
            NSLayoutConstraint(item: sidebarTableView, attribute: .top,      relatedBy: .equal, toItem: view,       attribute: .top),
            NSLayoutConstraint(item: sidebarTableView, attribute: .bottom,   relatedBy: .equal, toItem: view,       attribute: .bottom),
            NSLayoutConstraint(item: sidebarTableView, attribute: .leading,  relatedBy: .equal, toItem: sourceBar, attribute: .trailing).withPriority(.almostRequired),
            NSLayoutConstraint(item: sidebarTableView, attribute: .trailing, relatedBy: .equal, toItem: view,       attribute: .trailing)
        ])
        
        // Override constraint for hiding source bar
        tableViewFullWidth = sidebarTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        tableViewFullWidth?.isActive = hideSourceBar

        sourceInsetManager  = ScrollViewInsetManager(scrollView: sourceBar)
        sidebarInsetManager = ScrollViewInsetManager(scrollView: sidebarTableView)
        
        // We apply these layout margins after all property setting is done because for some reason
        // this causes a reload, which will crash if it is not from a valid set table view
        sidebarTableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 24.0)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedItem = self.selectedItem,
            let selectedIndex = items.index(of: selectedItem) {
            sidebarTableView?.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: max(bottomLayoutGuide.length, statusTabBarInset), right: 0.0)
        sourceInsetManager?.standardContentInset    = contentInsets
        sourceInsetManager?.standardIndicatorInset  = contentInsets
        sidebarInsetManager?.standardContentInset   = contentInsets
        sidebarInsetManager?.standardIndicatorInset = contentInsets
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if clearsSelectionOnViewWillAppear {
            selectedItem = nil
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sourceBar?.flashScrollIndicators()
        sidebarTableView?.flashScrollIndicators()
    }
    
    
    // MARK: - Table view data source
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: RegularSidebarTableViewCell.self, for: indexPath)
        cell.update(for: items[indexPath.row])
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return items[indexPath.row].isEnabled
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if selectedItem == item { return }
        
        selectedItem = item
        delegate?.sidebarViewController(self, didSelectItem: item)
    }
    
    
    // MARK: - Source bar delegate
    
    public func sourceBar(_ bar: SourceBar, didSelectItemAt index: Int) {
        selectedSourceIndex = index
        delegate?.sidebarViewController(self, didSelectSourceAt: index)
    }
    
    public func sourceBar(_ bar: SourceBar, didRequestToLoadItemAt index: Int) {
        delegate?.sidebarViewController(self, didRequestToLoadSourceAt: index)
    }
    
    
    
    // MARK: - Overrides
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sidebarItemContext {
            if isViewLoaded == false { return }
            
            guard let item = object as? SidebarItem, let key = keyPath,
                  let itemIndex = items.index(of: item) else { return }
            
            if key == #keyPath(SidebarItem.isEnabled) && item.isEnabled == false && selectedItem == item {
                selectedItem = nil
            }
            
            if let sidebarCell = sidebarTableView?.cellForRow(at: IndexPath(row: itemIndex, section: 0)) as? RegularSidebarTableViewCell {
                sidebarCell.update(for: item)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.theme(for: .current).statusBarStyle
    }
    
    
    // MARK: - Private methods
    
    private func updateSelection() {
        guard isViewLoaded, let tableView = sidebarTableView else { return }
        
        if let selectedItem = self.selectedItem,
            let index = items.index(of: selectedItem) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            let rect = tableView.rectForRow(at: indexPath)
            tableView.scrollRectToVisible(rect, animated: tableView.window != nil)
        } else if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
    
}
