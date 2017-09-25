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
            updatedItems(oldValue: oldValue)
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
            sourceViewController?.items = sourceItems

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
            sourceViewController?.selectedIndex = selectedSourceIndex

            if let selectedSourceIndex = selectedSourceIndex {
                precondition(selectedSourceIndex < sourceItems.count)
                sourceButton.setTitle(sourceItems[selectedSourceIndex].shortTitle, for: .normal)

                // Update color to match source status
                switch sourceItems[selectedSourceIndex].state {
                case .loaded(_, let color):
                    sourceButton.backgroundColor = color
                default:
                    sourceButton.backgroundColor = .lightGray
                }
            } else {
                sourceButton.setTitle(nil, for: .normal)
            }
        }
    }

    /// Whether source button should be hidden
    public var hideSourceButton: Bool = false {
        didSet {
            // Make scroll view full width and hide button if sources not visible
            scrollViewFullWidth?.isActive = hideSourceButton
            sourceButton.isHidden = hideSourceButton
            sourceDivider.isHidden = hideSourceButton
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

    /// The currently displayed source view controller, if any
    fileprivate var sourceViewController: CompactSidebarSourceViewController? = nil

    /// The leading constraint for the stack view, to center first item
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    private var stackViewTrailingConstraint: NSLayoutConstraint!

    /// Fade out affect for left side of scrollview
    private var fadeOutLeft: GradientView!

    /// Fade out affect for right side of scrollview
    private var fadeOutRight: GradientView!

    /// Constraint for making scrollview full width
    private var scrollViewFullWidth: NSLayoutConstraint?

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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.canCancelContentTouches = true
        scrollView.delegate = self
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
        sourceButton.backgroundColor = .lightGray
        sourceButton.setTitleColor(UIColor.black, for: .normal)
        sourceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        sourceButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        sourceButton.layer.cornerRadius = 3
        sourceButton.addTarget(self, action: #selector(didTapSourceButton(_:)), for: .touchUpInside)
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
            scrollView.leadingAnchor.constraint(equalTo: sourceDivider.trailingAnchor).withPriority(UILayoutPriorityRequired - 1),
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

        // Override constraint for hiding source button
        scrollViewFullWidth = scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        scrollViewFullWidth?.isActive = hideSourceButton
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
                setScrollOffsetForItem(itemIndex, additionalOffset: offset)
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

    @objc private func didTapSourceButton(_ item: UIBarButtonItem) {
        guard let selectedSourceIndex = selectedSourceIndex else { return }
        sourceViewController = CompactSidebarSourceViewController(items: sourceItems, selectedIndex: selectedSourceIndex)

        // Use modal style presentation, but with form sheet style nav styling
        // let navVC = PopoverNavigationController(rootViewController: sourceViewController!)
        // navVC.modalPresentationStyle = .formSheet

        // Use form sheet style presentation, even on phone
        let navVC = CompactFormSheetNavigationController(rootViewController: sourceViewController!, parent: navigationController!)
        present(navVC, animated: true, completion: nil)
    }

    private func updatedItems(oldValue: [SidebarItem]) {
        let items = self.items

        for item in oldValue where items.contains(item) == false {
            sidebarKeys.forEach { item.removeObserver(self, forKeyPath: $0, context: &sidebarItemContext) }
        }

        for item in items where oldValue.contains(item) == false {
            sidebarKeys.forEach { item.addObserver(self, forKeyPath: $0, context: &sidebarItemContext) }
        }

        // Add each sidebar item as a cell in the stack view
        items.forEach({ (item) in
            let label = CompactSidebarItemView(frame: .zero)
            label.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
            label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
            sidebarStackView.addArrangedSubview(label)
        })
        updateCells()

        if let selectedItem = self.selectedItem, items.contains(selectedItem) == false {
            self.selectedItem = nil
        }

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
            if !scrollView.isTracking && !scrollView.isDecelerating {
                self.setScrollOffsetForItem(index)
            }
        }
    }

    fileprivate func setScrollOffsetForItem(_ itemIndex: Int, additionalOffset: CGFloat = 0, animated: Bool = false) {
        let itemOffset = scrollOffsetForItem(itemIndex) + additionalOffset
        scrollView.setContentOffset(CGPoint(x: itemOffset, y: 0), animated: animated)
    }

    fileprivate func scrollOffsetForItem(_ itemIndex: Int) -> CGFloat {
        let cell = cells[itemIndex]
        let leftAligned = view.bounds.width + cell.frame.origin.x + scrollView.frame.origin.x
        let centerAligned = leftAligned - (view.bounds.width - cell.bounds.width) / 2
        return centerAligned
    }

}

// MARK: - CompactSidebarSourceViewControllerDelegate
extension CompactSidebarViewController: CompactSidebarSourceViewControllerDelegate {
    public func sourceViewControllerWillClose(_ viewController: CompactSidebarSourceViewController) {
        sourceViewController = nil
    }

    public func sourceViewController(_ viewController: CompactSidebarSourceViewController, didSelectItemAt index: Int) {
        delegate?.sidebarViewController(self, didSelectSourceAt: index)
    }

    public func sourceViewController(_ viewController: CompactSidebarSourceViewController, didRequestToLoadItemAt index: Int) {
        delegate?.sidebarViewController(self, didRequestToLoadSourceAt: index)
    }
}

// MARK: - UIScrollViewDelegate
extension CompactSidebarViewController: UIScrollViewDelegate {

    struct LayoutConstants {
        /// The amount of margin for bouncing off first and last items
        static let bounceMargin = 25 as CGFloat
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Set the scroll offset to the current item at end of scroll, if not decelerating
        if let selectedItem = selectedItem, let itemIndex = items.index(of: selectedItem), !decelerate {
            self.setScrollOffsetForItem(itemIndex, animated: true)
            self.delegate?.sidebarViewController(self, didSelectItem: selectedItem)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Set the scroll offset to the current item at end of deceleration
        // We only update delegate once the scroll is complete to prevent interrupting animation
        if let selectedItem = selectedItem, let itemIndex = items.index(of: selectedItem) {
            UIView.animate(withDuration: 0.3, animations: {
                self.setScrollOffsetForItem(itemIndex, animated: false)
            }, completion: { (completed) in
                self.delegate?.sidebarViewController(self, didSelectItem: selectedItem)
            })
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let selectedItem = selectedItem, let itemIndex = self.items.index(of: selectedItem) {
            let itemOffsets = items.enumerated().map({ (index, item) -> CGFloat in
                return scrollOffsetForItem(index)
            })

            if let minScroll = itemOffsets.first, let maxScroll = itemOffsets.last {
                // Prevent scrolling outside of first and last items (plus bounce margin)
                let constainedX = min(maxScroll + LayoutConstants.bounceMargin, max(minScroll - LayoutConstants.bounceMargin, scrollView.contentOffset.x))
                if scrollView.contentOffset.x != constainedX {
                    // End scroll movement early if hit edges and still moving
                    if scrollView.isDecelerating {
                        // Animate bounce back to item position (disabling delegate so we don't get callbacks during animation)
                        scrollView.delegate = nil
                        UIView.animate(withDuration: 0.3, animations: {
                            self.setScrollOffsetForItem(itemIndex, animated: false)
                        }, completion: { (completed) in
                            self.delegate?.sidebarViewController(self, didSelectItem: selectedItem)
                            scrollView.delegate = self
                        })
                        return
                    }
                    scrollView.contentOffset.x = constainedX
                    return
                }
            }
            // Highlight the nearest item if touching bar (giving preference to current item)
            let currentIndex = items.index(of: selectedItem)
            if scrollView.isTracking || scrollView.isDecelerating {
                let distances = itemOffsets.enumerated().map({ (index, offset) -> CGFloat in
                    let distance = abs(scrollView.contentOffset.x - offset)
                    return index == currentIndex ? distance * 0.8 : distance
                })
                let closestItemIndex = distances.index(of: distances.min()!)!
                let closestItem = items[closestItemIndex]
                if closestItem != self.selectedItem {
                    self.selectedItem = closestItem
                }
            }
        }
    }
}
