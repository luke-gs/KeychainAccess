//
//  CompactSidebarViewController.swift
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


/// Compact size-class version of sidebar used for displaying navigation items in a split view controller.
/// Items displayed in a horizontal strip
open class CompactSidebarViewController: UIViewController {

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

            if let selectedItem = self.selectedItem, items.contains(selectedItem) == false {
                self.selectedItem = nil
            }

            // Add each sidebar item as a cell in the stack view
            items.forEach({ (item) in
                let label = CompactSidebarItemView(frame: .zero)
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

    /// A Boolean value indicating whether the sidebar clears the selection when the view appears.
    ///
    /// The default value of this property is false. If true, the view controller clears the
    /// selectedItem when it receives a viewWillAppear(_:) message.
    open var clearsSelectionOnViewWillAppear: Bool = false

    /// The delegate for the sidebar, we use the same protocol as the vertical sidebar view controller.
    open weak var delegate: SidebarDelegate? = nil

    // MARK: - Private properties

    private struct LayoutConstants {
        static let scrollViewMargin: CGFloat = 10
    }

    /// The current stackview cells for items
    private var cells: [CompactSidebarItemView] {
        return sidebarStackView.arrangedSubviews as? [CompactSidebarItemView] ?? []
    }

    /// The leading constraint for the stack view, to center first item
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    private var stackViewTrailingConstraint: NSLayoutConstraint!

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
        scrollView.isScrollEnabled = false
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
        stackViewTrailingConstraint = sidebarStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0)
        stackViewTrailingConstraint.isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutConstants.scrollViewMargin),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.scrollViewMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.scrollViewMargin),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutConstants.scrollViewMargin),
            scrollView.heightAnchor.constraint(equalToConstant: 36),

            sidebarStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sidebarStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            sidebarStackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            stackViewLeadingConstraint,
            stackViewTrailingConstraint
        ])
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Add plenty of padding left and right of stackview, to allow for scroll based centering
        stackViewLeadingConstraint.constant = view.bounds.width
        stackViewTrailingConstraint.constant = -view.bounds.width

        // Update immediately when new layout
        UIView.performWithoutAnimation {
            self.updateCells()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if clearsSelectionOnViewWillAppear {
            selectedItem = nil
        }
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

    // MARK: - Public methods

    public func setScrollOffsetPercent(_ percent: CGFloat) {
        if let selectedItem = selectedItem, let itemIndex = items.index(of: selectedItem) {
            let fromCell = cells[itemIndex]
            var toCell: CompactSidebarItemView?
            if percent > 0 && itemIndex + 1 < cells.count {
                toCell = cells[itemIndex+1]
            } else if percent < 0 && itemIndex > 0 {
                toCell = cells[itemIndex-1]
            }

            if let toCell = toCell {
                // Scroll part way to next cell
                let offset = fabs(fromCell.center.x - toCell.center.x) * percent
                setScrollOffsetForItem(itemIndex, offset: offset, animated: false)
            }
        }
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

        cell.update(for: item, selected: selected)
        cell.selectHandler =  { [unowned self] in
            // If new selection, notify delegate
            if self.selectedItem == item { return }
            self.selectedItem = item
            self.delegate?.sidebarViewController(self, didSelectItem: item)
        }
        if selected {
            // Force layout of stack view as fonts have changed, and we need position of this item
            sidebarStackView.setNeedsLayout()
            sidebarStackView.layoutIfNeeded()
            setScrollOffsetForItem(index, offset: 0, animated: true)
        }
    }

    private func setScrollOffsetForItem(_ itemIndex: Int, offset: CGFloat, animated: Bool) {
        let cell = cells[itemIndex]
        let leftAligned = view.bounds.width + cell.frame.origin.x
        let centerAligned = leftAligned - (view.bounds.width - cell.bounds.width) / 2 + LayoutConstants.scrollViewMargin + offset
        scrollView.setContentOffset(CGPoint(x: centerAligned, y: 0), animated: animated)
    }

}
