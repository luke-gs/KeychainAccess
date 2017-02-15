//
//  SidebarViewController.swift
//  Test
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
                               #keyPath(SidebarItem.badgeColor),
                               #keyPath(SidebarItem.color),
                               #keyPath(SidebarItem.selectedColor)]


open class SidebarViewController: UIViewController {
    
    /// The current sidebar items available to display.
    public var sidebarItems: [SidebarItem] = [] {
        didSet {
            let sidebarItems = self.sidebarItems
            
            for item in oldValue where sidebarItems.contains(item) == false {
                sidebarKeys.forEach {
                    item.removeObserver(self, forKeyPath: $0, context: &sidebarItemContext)
                }
            }
            
            for item in sidebarItems where oldValue.contains(item) == false {
                sidebarKeys.forEach {
                    item.addObserver(self, forKeyPath: $0, context: &sidebarItemContext)
                }
            }
            
            sidebarTableView?.reloadData()
            
            if let selectedItem = self.selectedSidebarItem, sidebarItems.contains(selectedItem) == false {
                selectedSidebarItem = nil
            } else {
                updateSourceSelection()
            }
        }
    }
    
    /// The selected sidebar item.
    ///
    /// If `clearsSidebarSelectionOnViewWillAppear` is true, this property is set to nil
    /// when it receives a viewWillAppear(_:) message.
    public var selectedSidebarItem: SidebarItem? {
        didSet { updateSidebarSelection() }
    }
    
    /// The current sources available to display.
    ///
    /// When empty, the source list is hidden.
    public var sourceItems: [SidebarSourceItem] = [] {
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
    
    
    /// The table view for sidebar items.
    /// 
    /// This table view fills the sidebar, trailing the source bar if it appears.
    public fileprivate(set) var sidebarTableView: UITableView?
    
    /// The table view for source items.
    ///
    /// This table view is positioned at the leading edge, and only appears when source items exist.
    public fileprivate(set) var sourceTableView: UITableView?
    
    
    /// A Boolean value indicating whether the sidebar clears the selection when the view appears.
    ///
    /// The default value of this property is false. If true, the view controller clears the
    /// selectedSidebarItem when it receives a viewWillAppear(_:) message.
    open var clearsSidebarSelectionOnViewWillAppear: Bool = false
    
    
    /// The delegate for the sidebar.
    open weak var delegate: SidebarViewControllerDelegate? = nil
    
    fileprivate var sourceInsetManager: ScrollViewInsetManager?
    
    fileprivate var sidebarInsetManager: ScrollViewInsetManager?
    
    deinit {
        sidebarItems.forEach { item in
            sidebarKeys.forEach {
                item.removeObserver(self, forKeyPath: $0, context: &sidebarItemContext)
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sidebarItemContext {
            if isViewLoaded == false { return }
            
            guard let sidebarItem = object as? SidebarItem,
                  let key = keyPath,
                  let itemIndex = sidebarItems.index(of: sidebarItem) else { return }
            
            if key == #keyPath(SidebarItem.isEnabled) && sidebarItem.isEnabled == false && selectedSidebarItem == sidebarItem {
                selectedSidebarItem = nil
            }
            
            if let sidebarCell = sidebarTableView?.cellForRow(at: IndexPath(row: itemIndex, section: 0)) as? SidebarTableViewCell {
                sidebarCell.update(for: sidebarItem)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}

/// View lifecycle
extension SidebarViewController {
    
    open override func loadView() {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let sourceFrame  = CGRect(x: 0.0, y: 0.0, width: 64.0,  height: 480.0)
        let sidebarFrame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 480.0)
        
        let baseColor = #colorLiteral(red: 0.2604376972, green: 0.2660070062, blue: 0.292562902, alpha: 1)
        
        let sourceBackground = SidebarTableBackground(frame: sourceFrame)
        sourceBackground.topColor    = #colorLiteral(red: 0.07436346263, green: 0.0783027485, blue: 0.08661026508, alpha: 1)
        sourceBackground.bottomColor = baseColor
        
        let sidebarBackground = SidebarTableBackground(frame: sidebarFrame)
        sidebarBackground.topColor    = #colorLiteral(red: 0.1135626361, green: 0.1174433306, blue: 0.1298944652, alpha: 1)
        sidebarBackground.bottomColor = baseColor
        
        let sourceTableView = UITableView(frame: sourceFrame, style: .plain)
        sourceTableView.autoresizingMask = .flexibleHeight
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
        
        let sidebarTableView = UITableView(frame: sidebarFrame, style: .plain)
        sidebarTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sidebarTableView.backgroundView   = sidebarBackground
        sidebarTableView.dataSource = self
        sidebarTableView.delegate   = self
        sidebarTableView.separatorStyle = .none
        sidebarTableView.estimatedRowHeight = 50.0
        sidebarTableView.indicatorStyle = .white
        sidebarTableView.register(SidebarTableViewCell.self)
        view.addSubview(sidebarTableView)
        
        self.view             = view
        self.sourceTableView  = sourceTableView
        self.sidebarTableView = sidebarTableView
        
        sourceInsetManager  = ScrollViewInsetManager(scrollView: sourceTableView)
        sidebarInsetManager = ScrollViewInsetManager(scrollView: sidebarTableView)
        
        /* We apply these layout margins after all property setting is done because for some reason
           this causes a reload, which will crash if it is not from a valid set table view. */
        sidebarTableView.layoutMargins = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 24.0)
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
            
            if let sidebarTableView = self.sidebarTableView {
                var sidebarTableViewFrame      = sidebarTableView.frame
                let sidebarInsetWidth: CGFloat = hasNoSources ? 0.0 : 64.0
                
                sidebarTableViewFrame.origin.x   = isRightToLeft ? 0.0 : sidebarInsetWidth
                sidebarTableViewFrame.size.width = viewBounds.size.width - sidebarInsetWidth
                sidebarTableView.frame           = sidebarTableViewFrame
            }
        }
        
        let contentInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        sourceInsetManager?.standardContentInset    = contentInsets
        sourceInsetManager?.standardIndicatorInset  = contentInsets
        sidebarInsetManager?.standardContentInset   = contentInsets
        sidebarInsetManager?.standardIndicatorInset = contentInsets
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if clearsSidebarSelectionOnViewWillAppear {
            selectedSidebarItem = nil
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sourceTableView?.flashScrollIndicators()
        sidebarTableView?.flashScrollIndicators()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.layoutDirection != traitCollection.layoutDirection {
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
}

extension SidebarViewController : UITableViewDataSource, UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == sidebarTableView {
            return sidebarItems.count
        } else if tableView == sourceTableView {
            return sourceItems.count
        }
        fatalError("This table view is not supported by this view controller.")
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == sidebarTableView {
            let sidebarCell = tableView.dequeueReusableCell(of: SidebarTableViewCell.self, for: indexPath)
            sidebarCell.update(for: sidebarItems[indexPath.row])
            return sidebarCell
        } else if tableView == sourceTableView {
            let sourceCell = tableView.dequeueReusableCell(of: SourceTableViewCell.self, for: indexPath)
            sourceCell.update(for: sourceItems[indexPath.row])
            return sourceCell
        }
        fatalError("This table view is not supported by this view controller.")
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if tableView == sidebarTableView {
            return sidebarItems[indexPath.row].isEnabled
        } else if tableView == sourceTableView {
            return sourceItems[indexPath.row].isEnabled
        }
        fatalError("This table view is not supported by this view controller.")
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sidebarTableView {
            let sidebarItem = sidebarItems[indexPath.row]
            if selectedSidebarItem == sidebarItem { return }
            
            selectedSidebarItem = sidebarItem
            delegate?.sidebarViewController(self, didSelectItem: sidebarItem)
        } else if tableView == sourceTableView {
            if indexPath.row == selectedSourceIndex { return }
            
            selectedSourceIndex = indexPath.row
            delegate?.sidebarViewController(self, didSelectSourceAt: indexPath.row)
        }
    }
    
}

extension SidebarViewController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
}

extension SidebarViewController {
    
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
    
    fileprivate func updateSidebarSelection() {
        guard isViewLoaded, let tableView = sidebarTableView else { return }
        
        if let selectedItem = self.selectedSidebarItem,
            let index = sidebarItems.index(of: selectedItem) {
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
public protocol SidebarViewControllerDelegate : class {
    
    /// Indicates the sidebar has selected a new SidebarItem.
    ///
    /// - Parameters:
    ///   - controller: The `SidebarViewController` that has a new selection.
    ///   - item:       The newly selected item.
    func sidebarViewController(_ controller: SidebarViewController, didSelectItem item: SidebarItem)
    
    
    /// Indicates the sidebar has selected a new SidebarSourceItem.
    ///
    /// - Parameters:
    ///   - controller: The `SidebarViewController` that has a new selection.
    ///   - index:      The newly selected source index.
    func sidebarViewController(_ controller: SidebarViewController, didSelectSourceAt index: Int)
    
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
