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

    /// The delegate for the sidebar, we use the same protocol as the vertical sidebar view controller.
    open weak var delegate: SidebarDelegate? = nil

    /// The current items available to display.
    public var items: [SidebarItem] = [] {
        didSet {
            updateItems(oldValue: oldValue)
        }
    }

    /// The selected item.
    public var selectedItem: SidebarItem? {
        didSet {
            updateCells()
        }
    }

    /// The current sources available to display
    public var sourceItems: [SourceItem] = [] {
        didSet {
            if let selectedSourceIndex = selectedSourceIndex,
                selectedSourceIndex >= sourceItems.count {
                self.selectedSourceIndex = nil
            } else {
                let defaultIndex = sourceItems.count > 0 ? 0 : nil
                self.selectedSourceIndex = selectedSourceIndex ?? defaultIndex
            }
        }
    }

    /// The selected source index
    public var selectedSourceIndex: Int? = nil {
        didSet {
            if let selectedSourceIndex = selectedSourceIndex {
                precondition(selectedSourceIndex < sourceItems.count)
                sourceButton.setTitle(sourceItems[selectedSourceIndex].shortTitle, for: .normal)
            } else {
                sourceButton.setTitle(nil, for: .normal)
            }
        }
    }
    /// The stack view for sidebar items.
    public private(set) var sidebarStackView: UIStackView!

    /// The scroll view for containing the stack view.
    public private(set) var scrollView: UIScrollView!

    /// Button for changing the source
    public private(set) var sourceButton: UIButton!

    /// Divider line for source button and stack view
    public private(set) var sourceDivider: UIView!

    // MARK: - Private properties

    /// The current stackview cells for items
    private var cells: [CompactSidebarItemView] {
        return sidebarStackView.arrangedSubviews as? [CompactSidebarItemView] ?? []
    }

    /// The leading constraint for the stack view, to center first item
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    private var stackViewTrailingConstraint: NSLayoutConstraint!

    /// Fade out affect for left side of scrollview
    private var fadeOutLeft: GradientView!

    /// Fade out affect for right side of scrollview
    private var fadeOutRight: GradientView!

    /// The selected item index when pan gesture started
    private var panStartIndex = 0

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

        let backgroundColor = #colorLiteral(red: 0.1058823529, green: 0.1176470588, blue: 0.1411764706, alpha: 1)
        view.backgroundColor = backgroundColor

        scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanScrollView(gestureRecognizer:))))
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

        sourceButton = UIButton(type: .custom)
        sourceButton.translatesAutoresizingMaskIntoConstraints = false
        sourceButton.backgroundColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        sourceButton.setTitleColor(UIColor.black, for: .normal)
        sourceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        sourceButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        sourceButton.layer.cornerRadius = 3
        view.addSubview(sourceButton)

        sourceDivider = UIView(frame: .zero)
        sourceDivider.translatesAutoresizingMaskIntoConstraints = false
        sourceDivider.backgroundColor = UIColor.gray
        view.addSubview(sourceDivider)

        fadeOutLeft = GradientView()
        fadeOutLeft.translatesAutoresizingMaskIntoConstraints = false
        fadeOutLeft.gradientColors = [backgroundColor, UIColor.clear]
        fadeOutLeft.gradientDirection = .horizontal
        fadeOutLeft.isUserInteractionEnabled = false
        view.addSubview(fadeOutLeft)

        fadeOutRight = GradientView()
        fadeOutRight.translatesAutoresizingMaskIntoConstraints = false
        fadeOutRight.gradientColors = [UIColor.clear, backgroundColor]
        fadeOutRight.gradientDirection = .horizontal
        fadeOutRight.isUserInteractionEnabled = false
        view.addSubview(fadeOutRight)

        NSLayoutConstraint.activate([
            sourceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sourceButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            sourceDivider.leadingAnchor.constraint(equalTo: sourceButton.trailingAnchor, constant: 20),
            sourceDivider.topAnchor.constraint(equalTo: view.topAnchor),
            sourceDivider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sourceDivider.widthAnchor.constraint(equalToConstant: 1),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: sourceDivider.trailingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 56),

            sidebarStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            sidebarStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            sidebarStackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            stackViewLeadingConstraint,
            stackViewTrailingConstraint,

            fadeOutLeft.topAnchor.constraint(equalTo: scrollView.topAnchor),
            fadeOutLeft.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            fadeOutLeft.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            fadeOutLeft.widthAnchor.constraint(equalToConstant: 40),

            fadeOutRight.topAnchor.constraint(equalTo: scrollView.topAnchor),
            fadeOutRight.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            fadeOutRight.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            fadeOutRight.widthAnchor.constraint(equalToConstant: 40),
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

    private func updateItems(oldValue: [SidebarItem]) {
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

    private func updateCells() {
        // Animate any changes to the selected cell
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            for index in 0..<self.items.count {
                self.updateCellAtIndex(index)
            }
        }, completion: nil)
    }

    private func updateCellAtIndex(_ index: Int) {
        guard isViewLoaded, let sidebarStackView = sidebarStackView else { return }
        let item = items[index]
        let cell = cells[index]
        let selected = item == self.selectedItem

        cell.update(for: item, selected: selected)
        cell.selectHandler =  { [unowned self] in
            if self.selectedItem == item { return }
            // If new selection, animate scroll and notify delegate
            self.selectedItem = item
            self.delegate?.sidebarViewController(self, didSelectItem: item)
        }
        if selected {
            // Force layout of stack view as fonts have changed, and we need position of this item
            sidebarStackView.setNeedsLayout()
            sidebarStackView.layoutIfNeeded()
            self.setScrollOffsetForItem(index, offset: 0, animated: false)
        }
    }

    private func setScrollOffsetForItem(_ itemIndex: Int, offset: CGFloat, animated: Bool) {
        let cell = cells[itemIndex]
        let leftAligned = view.bounds.width + cell.frame.origin.x + scrollView.frame.origin.x
        let centerAligned = leftAligned - (view.bounds.width - cell.bounds.width) / 2 + offset
        scrollView.setContentOffset(CGPoint(x: centerAligned, y: 0), animated: animated)
    }

    @objc func didPanScrollView(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        switch gestureRecognizer.state {
        case .began:
            if let selectedItem = selectedItem, let itemIndex = items.index(of: selectedItem) {
                panStartIndex = itemIndex
            }
        case .changed:
            // Scroll to next or previous menu items based on translation from original index
            let newIndex = panStartIndex - Int(translation.x / 40)
            var newItem: SidebarItem? = nil
            if newIndex >= 0 && newIndex < items.count {
                newItem = items[newIndex]
            }
            if let newItem = newItem, newItem != selectedItem {
                // Select new item and notify delegate
                self.selectedItem = newItem
                self.delegate?.sidebarViewController(self, didSelectItem: newItem)
            }
        default:
            break
        }
    }

}
