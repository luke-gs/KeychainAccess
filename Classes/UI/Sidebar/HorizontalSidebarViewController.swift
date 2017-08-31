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

            // Add each sidebar item as a cell in the stack view
            items.forEach({ (item) in
                let label = HorizontalSidebarCell(frame: .zero)
                label.text = item.title
                label.textColor = item.color
                label.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
                label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
                sidebarStackView.addArrangedSubview(label)
            })

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

    /// The stack view for sidebar items.
    public private(set) var sidebarStackView: UIStackView!

    /// The scroll view for containing the stack view.
    public private(set) var scrollView: UIScrollView!

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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        sidebarStackView = UIStackView(frame: .zero)
        sidebarStackView.axis = .horizontal
        sidebarStackView.spacing = 10.0
        sidebarStackView.distribution = .equalSpacing
        sidebarStackView.alignment = .center
        sidebarStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(sidebarStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            scrollView.heightAnchor.constraint(equalToConstant: 56),

            sidebarStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sidebarStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            sidebarStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            sidebarStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            sidebarStackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])
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

//            if let sidebarCell = sidebarTableView?.cellForRow(at: IndexPath(row: itemIndex, section: 0)) as? SidebarTableViewCell {
//                sidebarCell.update(for: item)
//            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.theme(for: .current).statusBarStyle
    }

    // MARK: - Private methods

    private func updateSelection() {
        let unselectedColor      = #colorLiteral(red: 0.5450980392, green: 0.568627451, blue: 0.6235294118, alpha: 1)
        let badgeBackgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1803921569, blue: 0.2117647059, alpha: 1)
        guard isViewLoaded, let sidebarStackView = sidebarStackView else { return }

        for index in 0..<items.count {
            let item = items[index]
            let cell = cells[index]
            let selected = item == self.selectedItem
            cell.textColor = selected ? .white : unselectedColor

            if selected {
                let rect = cell.convert(cell.frame, to: sidebarStackView)
                scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }

}
