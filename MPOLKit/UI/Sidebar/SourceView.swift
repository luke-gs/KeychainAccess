//
//  SourceView.swift
//  MPOLKit
//
//  Created by Rod Brown on 8/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A control for displaying a source picker in MPOL applications.
///
/// Source view provides a soft "glow" on selected items, and can be configured to
/// optimize for light or dark contexts. When compressed the source bar allows scrolling
/// to further elements.
public class SourceView: GradientView {

    /// The style options available on SourceView.
    public enum Style {
        /// A light style. This appearance is optimized for display over lighter backgrounds.
        case light
        /// A dark style. This appearance is optimized for display over darker backgrounds.
        case dark
    }
    
    
    /// The currenty appearnace style. The default is `.dark`.
    public var style: Style = .dark {
        didSet {
            if style == oldValue { return }
            
            tableView.reloadData()
            tableView.indicatorStyle = self.style == .dark ? .white : .black
            
            if let selectedIndex = selectedIndex {
                tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    
    /// The items to display. The default is none.
    ///
    /// When there are no items, the source view prefers to compress to zero width
    /// to hide via AutoLayout.
    ///
    /// Setting this property doesn't update the selectedIndex property, except where the
    /// selected index would point to an item that is beyond the length of this array. In
    /// this case, the selected index becomes `nil`. It is recommended you update the
    /// selected index after each time you change the items.
    public var items: [SourceItem] = [] {
        didSet {
            if items != oldValue {
                tableView.reloadData()
            }
            if items.count != oldValue.count {
                if let selectedIndex = self.selectedIndex, selectedIndex >= items.count {
                    self.selectedIndex = nil
                }
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    
    /// The selected index. The default is `nil`.
    public var selectedIndex: Int? {
        didSet {
            if selectedIndex == oldValue { return }
            
            if let newIndex = selectedIndex {
                precondition(newIndex < items.count, "`selectedIndex` is invalid. Value must be less than the source item count")
                
                if items[newIndex].isEnabled == false { return }
                
                let indexPath = IndexPath(row: newIndex, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                tableView.scrollRectToVisible(tableView.rectForRow(at: indexPath), animated: isUserDrivenEvent)
            } else if let selectedIP = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIP, animated: false)
            }
        }
    }
    
    
    /// The delegate to receive messages when the user interacts with the source view.
    public weak var delegate: SourceViewDelegate?
    
    
    /// The scroll view internal of the view.
    ///
    /// This property is exposed to allow for adjusting content and scroll indicator insets
    /// to account for keyboard positions etc. You should not modify any other properties
    /// of the scroll view.
    public let scrollView: UIScrollView
    
    fileprivate let tableView: UITableView
    
    fileprivate var isUserDrivenEvent: Bool = false
    
    public override init(frame: CGRect) {
        tableView = UITableView(frame: .zero, style: .plain)
        scrollView = tableView
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        tableView = UITableView(frame: .zero, style: .plain)
        scrollView = tableView
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setContentCompressionResistancePriority(UILayoutPriorityDefaultLow,  for: .vertical)
        setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        setContentHuggingPriority(UILayoutPriorityFittingSizeLevel, for: .vertical)
        setContentHuggingPriority(UILayoutPriorityRequired - 1,     for: .horizontal)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.dataSource = self
        tableView.rowHeight = 77.0
        tableView.indicatorStyle = style == .dark ? .white : .black
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 64.0, height: 10.0))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 64.0, height: 10.0))
        tableView.register(SourceTableViewCell.self)
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: tableView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX),
            NSLayoutConstraint(item: tableView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY),
            NSLayoutConstraint(item: tableView, attribute: .width,   relatedBy: .equal, toItem: self, attribute: .width),
            NSLayoutConstraint(item: tableView, attribute: .height,  relatedBy: .equal, toItem: self, attribute: .height)
        ])
    }

}


extension SourceView: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        precondition(tableView == self.tableView, "SourceView only supports UITableViewDataSource methods for its own table view.")
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(tableView == self.tableView, "SourceView only supports UITableViewDataSource methods for its own table view.")
        
        let cell = tableView.dequeueReusableCell(of: SourceTableViewCell.self, for: indexPath)
        cell.update(for: items[indexPath.row], withStyle: style)
        return cell
    }
    
}


extension SourceView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        precondition(tableView == self.tableView, "SourceView only supports UITableViewDelegate methods for its own table view.")
        return items[indexPath.row].isEnabled
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        precondition(tableView == self.tableView, "SourceView only supports UITableViewDelegate methods for its own table view.")
        
        isUserDrivenEvent = true
        selectedIndex = indexPath.row
        isUserDrivenEvent = false
        
        delegate?.sourceView(self, didSelectItemAt: indexPath.row)
    }
    
}

extension SourceView {
    
    public override var intrinsicContentSize: CGSize {
        let sourceItemCount = items.count
        if sourceItemCount == 0 { return .zero }
        
        return CGSize(width: 64.0, height: CGFloat(sourceItemCount) * 88.0)
    }
    
}


/// The delegate of a `SourceView` object must adopt the SourceViewDelegate protocol.
/// The protocol provides callbacks for when the selected item changed.
public protocol SourceViewDelegate: class {
    
    func sourceView(_ view: SourceView, didSelectItemAt index: Int)
    
}
