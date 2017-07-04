//
//  FilterViewController.swift
//  MPOLKit_Example
//
//  Created by Rod Brown on 30/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

fileprivate let checkboxCellID = "CheckboxCellID"
fileprivate let radioCellID = "RadioCellID"


open class FilterViewController: FormCollectionViewController {
    
    open weak var delegate: FilterViewControllerDelegate?
    
    
    /// The filter options to display.
    ///
    /// - Important: Updating filter display options and counts after appearance is not supported.
    ///              You should only update this array to adjust selection state after display.
    ///
    /// - Note: Updating this array automatically updates validity.
    open var filterOptions: [FilterOption] {
        didSet {
            updateValidity()
        }
    }
    
    private let applyBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Apply", comment: ""), style: .done, target: nil, action: nil)
    
    private var selectedIndexPath: IndexPath?
    private weak var datePickerVC: PopoverDatePickerViewController?
    
    
    // MARK: - Initializers
    
    public init(options: [FilterOption]) {
        filterOptions = options
        
        super.init()
        preferredContentSize.width = 400.0
        
        formLayout.distribution = .fillEqually
        
        minimumCalculatedContentHeight = 200.0
        wantsCalculatedContentHeight = true
        
        isModalInPopover = true
        
        applyBarButtonItem.target = self
        applyBarButtonItem.action = #selector(applyItemDidSelect(_:))
        navigationItem.rightBarButtonItem = applyBarButtonItem
        navigationItem.leftBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelItemDidSelect(_:)))
    }
    
    /// FilterViewController does not support `NSCoding`.
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionView = self.collectionView!
        
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(FilterCheckmarkCell.self)
        collectionView.register(CollectionViewFormOptionCell.self, forCellWithReuseIdentifier: checkboxCellID)
        collectionView.register(CollectionViewFormOptionCell.self, forCellWithReuseIdentifier: radioCellID)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        var selectedIndexPaths: [IndexPath] = []
        
        filterOptions.enumerated().forEach { (section, option) in
            guard let list = option as? FilterList,
                list.displayStyle != .detailList
                else { return }
            
            let selectedOptions = list.selectedOptions
            list.options.enumerated().forEach {
                if selectedOptions.contains($1) {
                    selectedIndexPaths.append(IndexPath(item: $0, section: section))
                }
            }
        }
        
        selectedIndexPaths.forEach {
            collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndexPath = nil
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filterOptions.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterOptions[section].numberOfItems
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.text = filterOptions[indexPath.section].title?.ifNotEmpty()?.uppercased(with: .current)
            return header
        } else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch filterOptions[indexPath.section] {
        case let dateRange as FilterDateRange:
            let title: String
            let date: Date?
            let required: Bool
            
            if indexPath.item == 0 {
                title = NSLocalizedString("From", comment: "")
                date = dateRange.startDate
                required = dateRange.requiresStartDate
            } else {
                title = NSLocalizedString("Till", comment: "")
                date = dateRange.endDate
                required = dateRange.requiresEndDate
            }
            
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
            cell.highlightStyle = .fade
            cell.titleLabel.text = title
            if let date = date {
                cell.valueLabel.text = DateFormatter.shortDate.string(from: date)
            } else {
                cell.valueLabel.text = NSLocalizedString("Select", comment: "Unknown Date")
            }
            cell.setRequiresValidation(date == nil && required, validationText: nil, animated: false)
            return cell
        case let list as FilterList:
            switch list.displayStyle {
            case .checkbox:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: checkboxCellID, for: indexPath) as! CollectionViewFormOptionCell
                cell.optionStyle = .checkbox
                cell.titleLabel.text = (list.options[indexPath.item] as! Pickable).title
                cell.separatorStyle = .indentedAtRowLeading
                return cell
            case .radioControl:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: radioCellID, for: indexPath) as! CollectionViewFormOptionCell
                cell.optionStyle = .radio
                cell.titleLabel.text = (list.options[indexPath.item] as! Pickable).title
                cell.separatorStyle = .indentedAtRowLeading
                return cell
            case .list:
                let cell = collectionView.dequeueReusableCell(of: FilterCheckmarkCell.self, for: indexPath)
                cell.titleLabel.text = (list.options[indexPath.item] as! Pickable).title
                return cell
            case .detailList:
                let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
                cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
                let selectedItems = list.selectedOptions
                let selectedItemCount = selectedItems.count
                switch selectedItemCount {
                case 0:
                    cell.titleLabel.text = NSLocalizedString("Select", comment: "")
                    cell.setRequiresValidation(list.allowsNoSelection == false, validationText: nil, animated: false)
                case 1:
                    cell.titleLabel.text = (selectedItems.first as! Pickable).title
                    cell.setRequiresValidation(false, validationText: nil, animated: false)
                default:
                    cell.titleLabel.text = String(selectedItemCount) + NSLocalizedString(" items selected", comment: "")
                    cell.setRequiresValidation(list.allowsMultipleSelection == false, validationText: nil, animated: false)
                }
                return cell
            }
        default:
            MPLRequiresConcreteImplementation()
        }
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let checkmarkCell = cell as? FilterCheckmarkCell {
            checkmarkCell.unselectedTextColor = secondaryTextColor
            checkmarkCell.selectedTextColor = primaryTextColor
            checkmarkCell.updateTextColor()
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterOption = filterOptions[indexPath.section]
        
        switch filterOption {
        case var list as FilterList:
            switch list.displayStyle {
            case .checkbox, .radioControl, .list:
                var selectedOptions = list.selectedOptions
                let option = list.options[indexPath.item]
                let options = list.options
                if list.allowsMultipleSelection == false && selectedOptions.isEmpty == false {
                    var oldSelectedIndexPath = indexPath
                    selectedOptions.forEach {
                        if let index = options.index(of: $0), index != indexPath.item {
                            oldSelectedIndexPath.item = index
                            collectionView.deselectItem(at: oldSelectedIndexPath, animated: false)
                        }
                    }
                    selectedOptions.removeAll(keepingCapacity: true)
                }
                selectedOptions.insert(option)
                list.selectedOptions = selectedOptions
                filterOptions[indexPath.section] = list
            case .detailList:
                collectionView.deselectItem(at: indexPath, animated: true)
                
                let detailVC = FilterListPickerViewController(style: .plain, items: list.options)
                detailVC.title = list.title
                detailVC.selectedItems = list.selectedOptions
                detailVC.preferredContentSize.width = preferredContentSize.width
                detailVC.minimumCalculatedContentHeight = preferredContentSize.height
                detailVC.allowsMultipleSelection = list.allowsMultipleSelection
                detailVC.allowsNoSelection = list.allowsNoSelection
                detailVC.finishUpdateHandler = { [weak self] selections in
                    guard let `self` = self else { return }
                    
                    list.selectedOptions = selections
                    self.filterOptions[indexPath.section] = list
                    
                    UIView.performWithoutAnimation {
                        self.collectionView?.reloadItems(at: [indexPath])
                    }
                }
                
                show(detailVC, sender: self)
            }
        case var dateRange as FilterDateRange:
            collectionView.deselectItem(at: indexPath, animated: true)
            selectedIndexPath = indexPath
            
            let datePickerVC = PopoverDatePickerViewController()
            datePickerVC.preferredContentSize.width = preferredContentSize.width
            
            let datePicker = datePickerVC.datePicker
            datePicker.datePickerMode = .date
            
            let isStart = indexPath.item == 0
            let requiresDate: Bool
            let titleAddendum: String
            if isStart {
                titleAddendum = NSLocalizedString("From", comment: "")
                datePicker.maximumDate = dateRange.endDate
                datePicker.date = dateRange.startDate ?? dateRange.endDate ?? Date()
                requiresDate = dateRange.requiresStartDate
            } else {
                titleAddendum = NSLocalizedString("Till", comment: "")
                datePicker.minimumDate = dateRange.startDate
                datePicker.date = dateRange.endDate ?? dateRange.startDate ?? Date()
                requiresDate = dateRange.requiresEndDate
            }
            
            if let title = dateRange.title?.ifNotEmpty() {
                datePickerVC.title = title + ": " + titleAddendum
            } else {
                datePickerVC.title = titleAddendum
            }
            
            if requiresDate == false {
                datePickerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Clear", comment: ""), style: .plain, target: self, action: #selector(datePickerClearCurrentDate))
            }
            datePickerVC.finishUpdateHandler = { [weak self] date in
                guard let `self` = self else { return }
                if isStart {
                    dateRange.startDate = datePicker.calendar.startOfDay(for: date)
                } else {
                    dateRange.endDate = datePicker.calendar.endOfDay(for: date)
                }
                self.filterOptions[indexPath.section] = dateRange
                UIView.performWithoutAnimation {
                    collectionView.reloadItems(at: [indexPath])
                }
            }
            self.datePickerVC = datePickerVC
            show(datePickerVC, sender: self)
        default:
            MPLRequiresConcreteImplementation()
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard var list = filterOptions[indexPath.section] as? FilterList,
            list.displayStyle == .checkbox || list.displayStyle == .radioControl || list.displayStyle == .list
            else { return }
        
        let deselectedOption = list.options[indexPath.item]
        var selectedOptions = list.selectedOptions
        if let _ = selectedOptions.remove(deselectedOption) {
            list.selectedOptions = selectedOptions
            filterOptions[indexPath.section] = list
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let list = filterOptions[indexPath.section] as? FilterList,
            list.displayStyle == .checkbox || list.displayStyle == .radioControl || list.displayStyle == .list,
            list.selectedOptions.count == 1 && list.selectedOptions.contains(list.options[indexPath.item])
            else { return true }
        return list.allowsNoSelection
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    public func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout,
                             minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        switch filterOptions[indexPath.section] {
        case _ as FilterDateRange:
            return layout.columnContentWidth(forColumnCount: 2, sectionEdgeInsets: sectionEdgeInsets)
        case let list as FilterList:
            switch list.displayStyle {
            case .detailList, .list:
                return .greatestFiniteMagnitude
            case .checkbox:
                let maxWidth: CGFloat = list.options.reduce(0.0) {
                    guard let title = ($1 as? Pickable)?.title?.ifNotEmpty() else { return $0 }
                    return max($0, CollectionViewFormOptionCell.minimumContentWidth(withStyle: .checkbox, title: title, compatibleWith: traitCollection))
                }
                if maxWidth <=~ 0.0 {
                    return .greatestFiniteMagnitude
                }
                return layout.columnContentWidth(forMinimumItemContentWidth: maxWidth, sectionEdgeInsets: sectionEdgeInsets)
            case .radioControl:
                let maxWidth: CGFloat = list.options.reduce(0.0) {
                    guard let title = ($1 as? Pickable)?.title else { return $0 }
                    return max($0, CollectionViewFormOptionCell.minimumContentWidth(withStyle: .radio, title: title, compatibleWith: traitCollection))
                }
                if maxWidth <=~ 0.0 {
                    return .greatestFiniteMagnitude
                }
                return layout.columnContentWidth(forMinimumItemContentWidth: maxWidth, sectionEdgeInsets: sectionEdgeInsets)
            }
        default:
            MPLRequiresConcreteImplementation()
        }
    }
    
    // MARK: - Validity updating
    
    /// Updates the "apply" bar button item for the current filter option validity.
    ///
    /// This is automatically called whenever the `filterOptions` are set, which means
    /// value types automatically get this behavior. If you use reference types, you should
    /// call this method to update the item accordingly.
    open func updateValidity() {
        applyBarButtonItem.isEnabled = filterOptions.contains(where: { $0.isValid == false }) == false
    }
    
    
    // MARK: - Private methods
    
    @objc private func cancelItemDidSelect(_ item: UIBarButtonItem) {
        delegate?.filterViewControllerDidFinish(self, applyingChanges: false)
    }
    
    @objc private func applyItemDidSelect(_ item: UIBarButtonItem) {
        delegate?.filterViewControllerDidFinish(self, applyingChanges: true)
    }
    
    @objc private func datePickerClearCurrentDate() {
        if let indexPath = selectedIndexPath {
            datePickerVC?.finishUpdateHandler = nil // The finish update handler will call with the next pop, resetting the date. Disable it.
            
            var dateRange = filterOptions[indexPath.section] as! FilterDateRange
            if indexPath.item == 0 {
                dateRange.startDate = nil
            } else {
                dateRange.endDate = nil
            }            
            filterOptions[indexPath.section] = dateRange
            UIView.performWithoutAnimation {
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
        navigationController?.popToViewController(self, animated: true)
    }

}


// MARK: - FilterViewControllerDelegate

@objc public protocol FilterViewControllerDelegate {
    
    func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool)
    
}


// MARK: - Filter Options

public protocol FilterOption {
    var title: String? { get }
    var numberOfItems: Int { get }
    var isValid: Bool { get }
}

public struct FilterList: FilterOption {
    public enum DisplayStyle {
        case checkbox
        case radioControl
        case list
        case detailList
    }
    
    public let title: String?
    public let displayStyle: DisplayStyle
    public let options: [AnyHashable] // TODO: Swift 4: All options must be pickable
    public var selectedOptions: Set<AnyHashable> // TODO: Swift 4: All options must be pickable
    public let allowsNoSelection: Bool
    public let allowsMultipleSelection: Bool
    
    public var numberOfItems: Int {
        return displayStyle == .detailList ? 1 : options.count
    }
    
    public var isValid: Bool {
        if allowsNoSelection == false, selectedOptions.isEmpty {
            return false
        }
        if allowsMultipleSelection == false, selectedOptions.count > 1 {
            return false
        }
        return true
    }
    
    /// Intializes a filter list with a set of displayed options
    ///
    /// - Parameters:
    ///   - title: The title for the section, or `nil`.
    ///   - displayStyle: The display style for the list.
    ///   - options: All options available in the list. All options *must* conform to `Pickable`.
    ///   - selectedOptions: All selected options, or `nil`. All options in this set must be
    ///                      contained in `options`, and conform to `Pickable`.
    ///   - allowsNoSelection: A boolean value indicating whether no selection is avaialble.
    ///                        If `nil`, defaults to the standard for the display style - `true`
    ///                        for `.checkmark`, otherwise `false`. The default is `nil`.
    ///   - allowsMultipleSelection: A boolean value indicating whether multiple selection is avaialble.
    ///                        If `nil`, defaults to the standard for the display style - `true`
    ///                        for `.checkmark`, otherwise `false`. The default is `nil`.
    public init(title: String?, displayStyle: DisplayStyle, options: [AnyHashable], selectedOptions: Set<AnyHashable>?, allowsNoSelection: Bool? = nil, allowsMultipleSelection: Bool? = nil) {
        self.title = title
        self.displayStyle = displayStyle
        self.options = options
        self.selectedOptions = selectedOptions ?? []
        self.allowsNoSelection = allowsNoSelection ?? (displayStyle == .checkbox)
        self.allowsMultipleSelection = allowsMultipleSelection ?? (displayStyle == .checkbox)
    }
    
}

public struct FilterDateRange: FilterOption {
    public let title: String?
    public var startDate: Date?
    public var endDate: Date?
    public let requiresStartDate: Bool
    public let requiresEndDate: Bool
    
    public init(title: String?, startDate: Date?, endDate: Date?, requiresStartDate: Bool, requiresEndDate: Bool) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.requiresStartDate = requiresStartDate
        self.requiresEndDate = requiresEndDate
    }
    
    public var numberOfItems: Int {
        return 2
    }
    
    public var isValid: Bool {
        return (requiresStartDate == false || startDate != nil) && (requiresEndDate == false || endDate != nil)
    }
    
    public func contains(_ date: Date) -> Bool {
        if (startDate?.compare(date) ?? .orderedAscending) == .orderedDescending {
            return false
        }
        if (endDate?.compare(date) ?? .orderedDescending) == .orderedAscending {
            return false
        }
        return true
    }
}

fileprivate class FilterCheckmarkCell: CollectionViewFormSubtitleCell {
    
    var unselectedTextColor: UIColor?
    var selectedTextColor: UIColor?
    
    override var isSelected: Bool {
        didSet {
            if isSelected == oldValue { return }
            
            accessoryView = isSelected ? FormAccessoryCheckmark() : nil
            updateTextColor()
        }
    }
    
    func updateTextColor() {
        titleLabel.textColor = isSelected ? selectedTextColor : unselectedTextColor
    }
}


fileprivate extension Calendar {
    
    func endOfDay(for date: Date) -> Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfDay(for: date))
    }
    
}
