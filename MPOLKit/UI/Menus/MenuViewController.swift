//
//  MenuViewController.swift
//  Test
//
//  Created by Rod Brown on 11/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate var menuItemContext = 0
fileprivate let menuKeys = [#keyPath(MenuItem.isEnabled),
                            #keyPath(MenuItem.image),
                            #keyPath(MenuItem.selectedImage),
                            #keyPath(MenuItem.title),
                            #keyPath(MenuItem.count),
                            #keyPath(MenuItem.badgeColor),
                            #keyPath(MenuItem.color),
                            #keyPath(MenuItem.selectedColor)]


open class MenuViewController: UIViewController {
    
    /// The current items available to display.
    public var items: [MenuItem] = [] {
        didSet {
            let items = self.items
            
            for item in oldValue where items.contains(item) == false {
                menuKeys.forEach { item.removeObserver(self, forKeyPath: $0, context: &menuItemContext) }
            }
            
            for item in items where oldValue.contains(item) == false {
                menuKeys.forEach { item.addObserver(self, forKeyPath: $0, context: &menuItemContext) }
            }
            
            menuTableView?.reloadData()
            
            if let selectedItem = self.selectedItem, items.contains(selectedItem) == false {
                self.selectedItem = nil
            } else {
                updateSourceSelection()
            }
        }
    }
    
    /// The selected item.
    ///
    /// If `clearsSelectionOnViewWillAppear` is true, this property is set to nil
    /// when it receives a viewWillAppear(_:) message.
    public var selectedItem: MenuItem? {
        didSet { updateSelection() }
    }
    
    /// The current sources available to display.
    ///
    /// When empty, the source list is hidden.
    public var sourceItems: [SourceItem] = [] {
        didSet {
            viewIfLoaded?.setNeedsLayout()
            sourceTableView?.reloadData()
            updateSourceSelection()
        }
    }
    
    /// The selected source index.
    public var selectedSourceIndex: Int? = nil {
        didSet { updateSourceSelection() }
    }
    
    
    /// The table view for menu items.
    /// 
    /// This table view fills the menu, trailing the source bar if it appears.
    public fileprivate(set) var menuTableView: UITableView?
    
    
    /// The table view for source items.
    ///
    /// This table view is positioned at the leading edge, and only appears when source items exist.
    public fileprivate(set) var sourceTableView: UITableView?
    
    
    /// A Boolean value indicating whether the menu clears the selection when the view appears.
    ///
    /// The default value of this property is false. If true, the view controller clears the
    /// selectedItem when it receives a viewWillAppear(_:) message.
    open var clearsSelectionOnViewWillAppear: Bool = false
    
    
    /// The delegate for the menu.
    open weak var delegate: MenuViewControllerDelegate? = nil
    
    fileprivate var sourceInsetManager: ScrollViewInsetManager?
    
    fileprivate var menuInsetManager: ScrollViewInsetManager?
    
    deinit {
        items.forEach { item in
            menuKeys.forEach {
                item.removeObserver(self, forKeyPath: $0, context: &menuItemContext)
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &menuItemContext {
            if isViewLoaded == false { return }
            
            guard let item = object as? MenuItem, let key = keyPath,
                  let itemIndex = items.index(of: item) else { return }
            
            if key == #keyPath(MenuItem.isEnabled) && item.isEnabled == false && selectedItem == item {
                selectedItem = nil
            }
            
            if let menuCell = menuTableView?.cellForRow(at: IndexPath(row: itemIndex, section: 0)) as? MenuTableViewCell {
                menuCell.update(for: item)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}

/// View lifecycle
extension MenuViewController {
    
    open override func loadView() {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let sourceFrame  = CGRect(x: 0.0, y: 0.0, width: 64.0,  height: 480.0)
        let tableFrame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 480.0)
        
        let baseColor = #colorLiteral(red: 0.2604376972, green: 0.2660070062, blue: 0.292562902, alpha: 1)
        
        let sourceBackground = SidebarTableBackground(frame: sourceFrame)
        sourceBackground.topColor    = #colorLiteral(red: 0.07436346263, green: 0.0783027485, blue: 0.08661026508, alpha: 1)
        sourceBackground.bottomColor = baseColor
        
        let sidebarBackground = SidebarTableBackground(frame: tableFrame)
        sidebarBackground.topColor    = #colorLiteral(red: 0.1135626361, green: 0.1174433306, blue: 0.1298944652, alpha: 1)
        sidebarBackground.bottomColor = baseColor
        
        let sourceTableView = UITableView(frame: sourceFrame, style: .plain)
        sourceTableView.autoresizingMask = [.flexibleHeight]
        sourceTableView.backgroundView = sourceBackground
        sourceTableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 64.0, height: 10.0))
        sourceTableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 64.0, height: 10.0))
        sourceTableView.dataSource = self
        sourceTableView.delegate   = self
        sourceTableView.separatorStyle = .none
        sourceTableView.alwaysBounceVertical = false
        sourceTableView.rowHeight = 77.0
        sourceTableView.indicatorStyle = .white
        sourceTableView.register(SourceTableViewCell.self)
        view.addSubview(sourceTableView)
        
        let menuTableView = UITableView(frame: tableFrame, style: .plain)
        menuTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuTableView.backgroundView   = sidebarBackground
        menuTableView.dataSource = self
        menuTableView.delegate   = self
        menuTableView.separatorStyle = .none
        menuTableView.estimatedRowHeight = 50.0
        menuTableView.indicatorStyle = .white
        menuTableView.register(MenuTableViewCell.self)
        view.addSubview(menuTableView)
        
        self.view             = view
        self.sourceTableView  = sourceTableView
        self.menuTableView    = menuTableView
        
        sourceInsetManager  = ScrollViewInsetManager(scrollView: sourceTableView)
        menuInsetManager    = ScrollViewInsetManager(scrollView: menuTableView)
        
        /* We apply these layout margins after all property setting is done because for some reason
           this causes a reload, which will crash if it is not from a valid set table view. */
        menuTableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 24.0)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let view = self.view {
            
            let isRightToLeft = traitCollection.layoutDirection == .rightToLeft
            
            let viewBounds = view.bounds
            let hasNoSources = sourceItems.isEmpty
            
            if let sourceTableView = sourceTableView {
                sourceTableView.isHidden = hasNoSources
                sourceTableView.frame.origin.x = isRightToLeft ? viewBounds.maxX - 64.0 : 0.0
            }
            
            if let tableView = self.menuTableView {
                var tableViewFrame      = tableView.frame
                let insetWidth: CGFloat = hasNoSources ? 0.0 : 64.0
                
                tableViewFrame.origin.x   = isRightToLeft ? 0.0 : insetWidth
                tableViewFrame.size.width = viewBounds.size.width - insetWidth
                tableView.frame           = tableViewFrame
            }
        }
        
        let contentInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        sourceInsetManager?.standardContentInset    = contentInsets
        sourceInsetManager?.standardIndicatorInset  = contentInsets
        menuInsetManager?.standardContentInset   = contentInsets
        menuInsetManager?.standardIndicatorInset = contentInsets
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if clearsSelectionOnViewWillAppear {
            selectedItem = nil
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sourceTableView?.flashScrollIndicators()
        menuTableView?.flashScrollIndicators()
    }
    
//    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if previousTraitCollection?.layoutDirection != traitCollection.layoutDirection {
//            viewIfLoaded?.setNeedsLayout()
//        }
//    }
    
}

extension MenuViewController : UITableViewDataSource, UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == menuTableView {
            return items.count
        } else if tableView == sourceTableView {
            return sourceItems.count
        }
        fatalError("This table view is not supported by this view controller.")
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == menuTableView {
            let cell = tableView.dequeueReusableCell(of: MenuTableViewCell.self, for: indexPath)
            cell.update(for: items[indexPath.row])
            return cell
        } else if tableView == sourceTableView {
            let sourceCell = tableView.dequeueReusableCell(of: SourceTableViewCell.self, for: indexPath)
            sourceCell.update(for: sourceItems[indexPath.row])
            return sourceCell
        }
        fatalError("This table view is not supported by this view controller.")
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if tableView == menuTableView {
            return items[indexPath.row].isEnabled
        } else if tableView == sourceTableView {
            return sourceItems[indexPath.row].isEnabled
        }
        fatalError("This table view is not supported by this view controller.")
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            let item = items[indexPath.row]
            if selectedItem == item { return }
            
            selectedItem = item
            delegate?.menuViewController(self, didSelectItem: item)
        } else if tableView == sourceTableView {
            if indexPath.row == selectedSourceIndex { return }
            
            selectedSourceIndex = indexPath.row
            //delegate?.menuViewController(self, didSelectSourceAt: indexPath.row)
        }
    }
    
}

extension MenuViewController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
}

extension MenuViewController {
    
    fileprivate func updateSourceSelection() {
        if let selectedIndex = selectedSourceIndex, selectedIndex < sourceItems.count, sourceItems[selectedIndex].isEnabled {
            if let sourceTableView = self.sourceTableView {
                let indexPath = IndexPath(row: selectedIndex, section: 0)
                sourceTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                
                let rect = sourceTableView.rectForRow(at: indexPath)
                sourceTableView.scrollRectToVisible(rect, animated: sourceTableView.window != nil)
            }
        } else {
            if selectedSourceIndex != nil { selectedSourceIndex = nil }
            if let sourceTableView = self.sourceTableView,
                let selectedIndexPath = sourceTableView.indexPathForSelectedRow {
                sourceTableView.deselectRow(at: selectedIndexPath, animated: false)
            }
        }
    }
    
    fileprivate func updateSelection() {
        guard isViewLoaded, let tableView = menuTableView else { return }
        
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


/// The SidebarViewController's delegate protocol
///
/// Implement this protocol when you want to observe selection actions within
/// a sidebar.
public protocol MenuViewControllerDelegate : class {
    
    /// Indicates the sidebar has selected a new SidebarItem.
    ///
    /// - Parameters:
    ///   - controller: The `MenuViewController` that has a new selection.
    ///   - item:       The newly selected item.
    func menuViewController(_ controller: MenuViewController, didSelectItem item: MenuItem)
    
}



/// A private class for the sidebar table background.
fileprivate class SidebarTableBackground: UIView {
    
    var topColor    = #colorLiteral(red: 0.1723541915, green: 0.1761130691, blue: 0.1968527734, alpha: 1) { didSet { setNeedsDisplay() }}
    var bottomColor = #colorLiteral(red: 0.1723541915, green: 0.1761130691, blue: 0.1968527734, alpha: 1) { didSet { setNeedsDisplay() }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let gradient = CGGradient(colorsSpace: nil, colors: [topColor.cgColor, bottomColor.cgColor] as CFArray, locations: nil) else { return }
        
        let bounds = self.bounds
        let start = CGPoint(x: rect.midX, y: bounds.minY)
        let end   = CGPoint(x: rect.midX, y: bounds.maxY)
        context.drawLinearGradient(gradient, start: start, end: end, options: [])
    }
    
}
