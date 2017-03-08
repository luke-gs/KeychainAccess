//
//  SourceView.swift
//  MPOLKit
//
//  Created by Rod Brown on 8/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class SourceView: GradientView {

    public enum Style: Int {
        case light
        case dark
    }
    
    public var style: Style = .dark {
        didSet {
            tableView.reloadData()
            
            if let selectedIndex = selectedIndex {
                tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
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
    
    public weak var delegate: SourceViewDelegate?
    
    public var scrollView: UIScrollView {
        return tableView
    }
    
    fileprivate let tableView = UITableView(frame: .zero, style: .plain)
    
    fileprivate var isUserDrivenEvent: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
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
        tableView.indicatorStyle = .white
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 64.0, height: 10.0))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 64.0, height: 10.0))
        tableView.register(SourceTableViewCell.self, forCellReuseIdentifier: "sourceCellID")
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceCellID", for: indexPath) as! SourceTableViewCell
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


public protocol SourceViewDelegate: class {
    
    func sourceView(_ view: SourceView, didSelectItemAt index: Int)
    
}
