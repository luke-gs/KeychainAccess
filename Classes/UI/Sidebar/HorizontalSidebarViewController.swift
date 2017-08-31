//
//  HorizontalSidebarViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 31/8/17.
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


open class HorizontalSidebarViewController: UIViewController {

    // MARK: - Public properties

    /// The current stackview cells for items
    private var cells: [HorizontalSidebarCell] {
        return sidebarStackView.arrangedSubviews as? [HorizontalSidebarCell] ?? []
    }

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

            if let selectedItem = self.selectedItem, items.contains(selectedItem) == false {
                self.selectedItem = nil
            }

            // Add each sidebar item as a cell in the stack view
            items.forEach({ (item) in
                let label = HorizontalSidebarCell(frame: .zero)
                label.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
                label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
                sidebarStackView.addArrangedSubview(label)
            })
            updateCells()

            // Force layout so that we can get the cell size in viewDidLayoutSubviews
            sidebarStackView.setNeedsLayout()
            sidebarStackView.layoutIfNeeded()
        }
    }

    /// The selected item.
    ///
    /// If `clearsSelectionOnViewWillAppear` is true, this property is set to nil
    /// when it receives a viewWillAppear(_:) message.
    public var selectedItem: SidebarItem? {
        didSet {
            updateCells()
        }
    }

    /// The stack view for sidebar items.
    public private(set) var sidebarStackView: UIStackView!

    /// The scroll view for containing the stack view.
    public private(set) var scrollView: UIScrollView!

    /// The leading constraint for the stack view, to center first item
    private var stackViewLeadingConstraint: NSLayoutConstraint!

    /// A Boolean value indicating whether the sidebar clears the selection when the view appears.
    ///
    /// The default value of this property is false. If true, the view controller clears the
    /// selectedItem when it receives a viewWillAppear(_:) message.
    open var clearsSelectionOnViewWillAppear: Bool = false

    /// The delegate for the sidebar, we use the same protocol as the vertical sidebar view controller.
    open weak var delegate: SidebarViewControllerDelegate? = nil


    // MARK: - Private properties


    // MARK: - Initializer

    deinit {
        items.forEach { item in
            sidebarKeys.forEach {
                item.removeObserver(self, forKeyPath: $0, context: &sidebarItemContext)
            }
        }
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)

        scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        sidebarStackView = UIStackView(frame: .zero)
        sidebarStackView.axis = .horizontal
        sidebarStackView.spacing = 24.0
        sidebarStackView.distribution = .equalSpacing
        sidebarStackView.alignment = .center
        sidebarStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(sidebarStackView)

        stackViewLeadingConstraint = sidebarStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0)
        stackViewLeadingConstraint.isActive = true

        let inset = 10 as CGFloat
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset),
            scrollView.heightAnchor.constraint(equalToConstant: 36),

            sidebarStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sidebarStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            sidebarStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            sidebarStackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            stackViewLeadingConstraint
        ])
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let firstCell = self.cells.first, firstCell.bounds.width > 0 {
            self.stackViewLeadingConstraint.constant = (self.view.bounds.width - firstCell.bounds.width - 20) / 2
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if clearsSelectionOnViewWillAppear {
            selectedItem = nil
        }
    }

    // MARK: - Table view delegate

//    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return items[indexPath.row].isEnabled
//    }
//
//    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = items[indexPath.row]
//        if selectedItem == item { return }
//
//        selectedItem = item
//        delegate?.sidebarViewController(self, didSelectItem: item)
//    }


    // MARK: - Overrides

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sidebarItemContext {
            if isViewLoaded == false { return }

            guard let item = object as? SidebarItem, let key = keyPath,
                let itemIndex = items.index(of: item) else { return }

            if key == #keyPath(SidebarItem.isEnabled) && item.isEnabled == false && selectedItem == item {
                selectedItem = nil
            }
            // Animate the change to the cell
            UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.updateCellAtIndex(itemIndex)
            }, completion: nil)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.theme(for: .current).statusBarStyle
    }

    // MARK: - Private methods

    private func updateCells() {
        for index in 0..<items.count {
            updateCellAtIndex(index)
        }
    }

    private func updateCellAtIndex(_ index: Int) {
        guard isViewLoaded, let sidebarStackView = sidebarStackView else { return }

        let item = items[index]
        let cell = cells[index]
        let selected = item == self.selectedItem
        if let title = item.title {
            cell.text = item.count > 0 ? "\(item.count) \(title)" : title
        }
        cell.textColor = selected ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.5450980392, green: 0.568627451, blue: 0.6235294118, alpha: 1)
        cell.font = selected ? UIFont.systemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)

        if selected {
            let rect = cell.convert(cell.frame, to: sidebarStackView)
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }

}
