//
//  SearchOptionsViewController.swift
//  Pods
//
//  Created by Valery Shorinov on 31/3/17.
//
//

import UIKit
import MPOLKit

fileprivate var kvoContext = 1

open class SearchOptionsViewController: FormCollectionViewController, SearchCollectionViewCellDelegate, PopoverTableViewDelegate, NumberRangePickerDelegate {
    
    enum SearchSegments: Int {
        case person = 0, vehicle, organisation, location
    }
    
    var searchSources : [SearchType] = []
    var isFiltersHidden : Bool = true
    
    var segmentIndex = 0
    
    public init(items : [SearchType]? = nil) {
        
        super.init()
        
        if let sourceArray = items {
            searchSources = sourceArray
        } else {
            // For testing
            setupDefaultFilters()
        }
    }
    
    public override init() {
        super.init()
        
        setupDefaultFilters()
    }
    
    private func setupDefaultFilters() {
        searchSources = [PersonSearchType(), VehicleSearchType(), OrganizationSearchType(), LocationSearchType()]
    }
    
    deinit {
        collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    // MARK - View Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(SearchCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewGlobalFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.alwaysBounceVertical = false
        
        collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let searchCell = collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
            searchCell.searchTextField.becomeFirstResponder()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        collectionView?.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Editing
    
    func beginEditingSearchField() {
        if let searchCell = collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
            searchCell.searchTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if object is UICollectionView {
                if let contentSize = self.collectionView?.contentSize {
                    self.preferredContentSize = contentSize
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - CollectionView Methods
    
    // Default global footer
    class CollectionViewGlobalFooterView: UICollectionReusableView, DefaultReusable {
        public static let minimumHeight: CGFloat = 20.0
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if segmentIndex == SearchSegments.location.rawValue {
            return 1
        }
        
        return isFiltersHidden == true ? 1 : 2
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 {
            
            let source = searchSources[segmentIndex]

            return source.numberOfFilters
        }
        
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.tapHandler       = nil
            header.text = "FILTER SEARCH"
            return header
        } else if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewGlobalFooterView.self, for: indexPath)
            
            return footer
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, heightForGlobalFooterInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return CollectionViewGlobalFooterView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(of: SearchCollectionViewCell.self, for: indexPath)
            
            cell.searchSources = searchSources
            cell.searchCollectionViewCellDelegate = self
            cell.sourceSegmentationController.selectedSegmentIndex = segmentIndex
            cell.separatorStyle = .none
            
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            
            cell.emphasis = .subtitle
            cell.isEditableField = false
            cell.subtitleLabel.numberOfLines = 1
            cell.separatorStyle = .none
            
            let source = searchSources[segmentIndex]
            
            cell.titleLabel.text = source.filterTitle(atIndex: indexPath.item)
            cell.subtitleLabel.text = source.filterValue(atIndex: indexPath.item)
            cell.separatorStyle = .indented
            
            if source.filterIsEmpty(atIndex: indexPath.item) {
                cell.subtitleLabel.alpha = 0.6
            } else {
                cell.subtitleLabel.alpha = 1.0
            }
            
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: - CollectionView Delegates
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = indexPath.item
        
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
            cell.searchTextField.resignFirstResponder()
        }
        
        if indexPath.section == 1 {
            switch segmentIndex {
            case SearchSegments.person.rawValue:
                if let personFilter = searchSources[segmentIndex] as? PersonSearchType {
                    
                    if index == PersonSearchType.PersonFilterType.age.rawValue {
                        
                        var minValue = 0
                        var maxValue = 0
                        
                        let indexes = personFilter.filterSelectedOptions(atIndex: index)
                        
                        if let min = indexes.min() {
                            minValue = min
                        }
                        
                        if let max = indexes.max() {
                            maxValue = max
                        }
                        
                        let pickerView = SearchNumberRangePickerViewController(min: 0, max: 120, currentMin: minValue, currentMax:maxValue)
                        pickerView.title = personFilter.filterTitle(atIndex: index)
                        pickerView.numberRangePickerDelegate = self
                        pickerView.linkedSegmentAndIndex = IndexPath(item:index, section:segmentIndex)
                        
                        let popover = PopoverNavigationController(rootViewController: pickerView)
                        popover.modalPresentationStyle = .popover
                        
                        if let presentationController = popover.popoverPresentationController {
                            
                            let cell = collectionView.cellForItem(at:indexPath)
                            
                            presentationController.sourceView = cell
                            presentationController.sourceRect = cell!.bounds
                            
                        }
                        
                        present(popover, animated: true, completion: nil)
                        
                        return
                    }
                    
                    let tableView = PopoverSelectableTableViewController(style: .plain)
                    tableView.sourceItems = personFilter.filterOptions(atIndex: index)
                    tableView.title = personFilter.filterTitle(atIndex: index)
                    tableView.popoverTableViewDelegate = self
                    tableView.linkedSegmentAndIndex = IndexPath(item:index, section:segmentIndex)
                    
                    switch index {
                    case PersonSearchType.PersonFilterType.searchType.rawValue:
                        tableView.mustHaveValue = true
                        tableView.selectedItemsIndex = personFilter.filterSelectedOptions(atIndex: index)
                        break
                    case PersonSearchType.PersonFilterType.state.rawValue:
                        tableView.defaultValue = personFilter.filterDefaultText(atIndex: index)
                        tableView.canMultiSelect = true
                        tableView.selectedItemsIndex = personFilter.filterSelectedOptions(atIndex: index)
                        break
                    case PersonSearchType.PersonFilterType.gender.rawValue:
                        tableView.defaultValue = personFilter.filterDefaultText(atIndex: index)
                        tableView.canMultiSelect = true
                        tableView.selectedItemsIndex = personFilter.filterSelectedOptions(atIndex: index)
                        break
                    default:
                        break
                    }
                    
                    let popover = PopoverNavigationController(rootViewController: tableView)
                    popover.modalPresentationStyle = .popover
                    
                    if let presentationController = popover.popoverPresentationController {
                        
                        let cell = collectionView.cellForItem(at:indexPath)
                        
                        presentationController.sourceView = cell
                        presentationController.sourceRect = cell!.bounds
                        
                    }
                    
                    present(popover, animated: true, completion: nil)
                }
                break
            case SearchSegments.vehicle.rawValue:
                if let vehicleFilter = searchSources[segmentIndex] as? VehicleSearchType {
                    
                    let tableView = PopoverSelectableTableViewController(style: .plain)
                    tableView.sourceItems = vehicleFilter.filterOptions(atIndex: index)
                    tableView.title = vehicleFilter.filterTitle(atIndex: index)
                    tableView.popoverTableViewDelegate = self
                    tableView.linkedSegmentAndIndex = IndexPath(item:index, section:segmentIndex)
                    
                    switch index {
                    case VehicleSearchType.VehicleFilterType.searchType.rawValue:
                        tableView.mustHaveValue = true
                        tableView.selectedItemsIndex = vehicleFilter.filterSelectedOptions(atIndex: index)
                        break
                    case VehicleSearchType.VehicleFilterType.state.rawValue, VehicleSearchType.VehicleFilterType.make.rawValue, VehicleSearchType.VehicleFilterType.model.rawValue:
                        tableView.defaultValue = vehicleFilter.filterDefaultText(atIndex: index)
                        tableView.canMultiSelect = true
                        tableView.selectedItemsIndex = vehicleFilter.filterSelectedOptions(atIndex: index)
                        break
                    default:
                        break
                    }
                    
                    let popover = PopoverNavigationController(rootViewController: tableView)
                    popover.modalPresentationStyle = .popover
                    
                    if let presentationController = popover.popoverPresentationController {
                        
                        let cell = collectionView.cellForItem(at:indexPath)
                        
                        presentationController.sourceView = cell
                        presentationController.sourceRect = cell!.bounds
                        
                    }
                    
                    present(popover, animated: true, completion: nil)
                }
                break
            case SearchSegments.organisation.rawValue:
                
                break
            default:
                
                break
            }
        }
    }
    
    // MARK: - CollectionViewDelegate MPOLLayout Methods
    
    public func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        if traitCollection.horizontalSizeClass == .compact {
            return collectionView.bounds.width * 0.6
        }
        return 0.0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        
        return section == 0 ? 0.0 : CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        if indexPath.section == 0 && indexPath.item == 0 {
            return SearchCollectionViewCell.cellHeight()
        }
        
        var title: String? = ""
        var subtitle: String? = ""
        
        let source = searchSources[segmentIndex]
        
        title = source.filterTitle(atIndex: indexPath.item)
        subtitle = source.filterValue(atIndex: indexPath.item)

        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, emphasis: .subtitle, singleLineSubtitle: true)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        
        let preferredContentSizeCategory: UIContentSizeCategory
        if #available(iOS 10, *) {
            let category = traitCollection.preferredContentSizeCategory
            preferredContentSizeCategory = category == UIContentSizeCategory.unspecified ? .large : category
        } else {
            // references to the shared application are banned in extensions but this actually still works
            // in apps and gets us the preferred content size. This is part of why they moved preferred
            // content size category into trait collections as it couldn't be accessed on UIApplication
            // in extensions (and MPOLKit is restrcted to extension-only API)
            preferredContentSizeCategory = (UIApplication.value(forKey: "sharedApplication") as! UIApplication).preferredContentSizeCategory
        }
        
        let extraLargeText: Bool
        
        switch preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        
        let minimumWidth: CGFloat
        let maxColumnCount: Int
        
        if indexPath.section == 0 {
            return sectionWidth
        } else {
            minimumWidth = extraLargeText ? 250.0 : 140.0
            maxColumnCount = 4
        }
        
        return layout.columnContentWidth(forMinimumItemContentWidth: minimumWidth, maximumColumnCount: maxColumnCount, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: UIScreen.main.scale)
    }
    
    // MARK: - SearchCollectionViewCell Delegates
    
    public func searchCollectionViewCell(_ cell: SearchCollectionViewCell, didChangeText text: String?) {
        
        if isFiltersHidden && !(text?.isEmpty)! { // Show filters
            isFiltersHidden = false
            collectionView?.reloadData()
            collectionView?.layoutIfNeeded()
            if let cell = collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
                cell.searchTextField.becomeFirstResponder()
            }
        } else if !isFiltersHidden && (text?.isEmpty)! { // Hide Filters
            isFiltersHidden = true
            collectionView?.reloadData()
            collectionView?.layoutIfNeeded()
            if let cell = collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
                cell.searchTextField.becomeFirstResponder()
            }
        }
    }
    
    public func searchCollectionViewCell(_ cell: SearchCollectionViewCell, didSelectSegmentAt index: Int) {
        segmentIndex = index
        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
        if let cell = collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
            cell.searchTextField.becomeFirstResponder()
        }
    }
    
    // MARK - PopoverTableView Delegate
    func popoverTableSelectionChanged(_ tableView: PopoverSelectableTableViewController, newValues: IndexSet) {
        print("Value changed")
        
        if newValues.count > 0 {
            for index in newValues {
                print("Index:\(index)")
            }
        }
        
        if let segmentAndIndex = tableView.linkedSegmentAndIndex {
            switch segmentAndIndex.section {
            case SearchSegments.person.rawValue:
                if let personFilter = searchSources[segmentIndex] as? PersonSearchType {
                    switch segmentAndIndex.item {
                    case PersonSearchType.PersonFilterType.searchType.rawValue:
                        if let options = tableView.sourceItems {
                            for index in newValues {
                                if (personFilter.set(value: options[index], atIndex: segmentAndIndex.item)) {
                                    collectionView?.reloadData()
                                }
                            }
                        }
                        break
                    case PersonSearchType.PersonFilterType.state.rawValue, PersonSearchType.PersonFilterType.gender.rawValue:
                        if let options = tableView.sourceItems {
                            var selectedValues: [String] = []
                            for index in newValues {
                                selectedValues.append(options[index])
                            }
                            
                            if (personFilter.set(value: selectedValues, atIndex: segmentAndIndex.item)) {
                                collectionView?.reloadData()
                            }
                        }
                        break
                    default:
                        break
                    }
                }
            case SearchSegments.vehicle.rawValue:
                if let vehicleFilter = searchSources[segmentIndex] as? VehicleSearchType {
                    switch segmentAndIndex.item {
                    case VehicleSearchType.VehicleFilterType.searchType.rawValue:
                        if let options = tableView.sourceItems {
                            for index in newValues {
                                if (vehicleFilter.set(value: options[index], atIndex: segmentAndIndex.item)) {
                                    collectionView?.reloadData()
                                }
                            }
                        }
                        break
                    case VehicleSearchType.VehicleFilterType.state.rawValue, VehicleSearchType.VehicleFilterType.make.rawValue, VehicleSearchType.VehicleFilterType.model.rawValue:
                        if let options = tableView.sourceItems {
                            var selectedValues: [String] = []
                            for index in newValues {
                                selectedValues.append(options[index])
                            }
                            
                            if (vehicleFilter.set(value: selectedValues, atIndex: segmentAndIndex.item)) {
                                collectionView?.reloadData()
                            }
                        }
                        break
                    default:
                        break
                    }
                }
                break
            default:
                
                break
            }
        }
    }
    
    // MARK - NumberPicker Delegate
    
    func numberRangePickerValueChanged(_ numberPicker: SearchNumberRangePickerViewController, newMinValue: Int, newMaxValue: Int) {
        print("ValueChanged Min:\(newMinValue) Max:\(newMaxValue)")
        
        if let segmentAndIndex = numberPicker.linkedSegmentAndIndex {
            switch segmentAndIndex.section {
            case SearchSegments.person.rawValue:
                if let personFilter = searchSources[segmentIndex] as? PersonSearchType {
                    switch segmentAndIndex.item {
                    case PersonSearchType.PersonFilterType.age.rawValue:
                        if personFilter.set(value: Range(uncheckedBounds: (newMinValue, newMaxValue)), atIndex: segmentAndIndex.item) == true {
                            collectionView?.reloadData()
                        }
                        break
                    default:
                        break
                    }
                }
                break
            default:
                break
            }
        }
    }
    
}

// MARK - Search Type Classes

public class SearchType: NSObject {
    public var title: String { return "" }
    public var endpoint: String { return "" }
    public var numberOfFilters: Int { return 0 }
    
    public func filterValue(atIndex: Int) -> String {
        return ""
    }
    
    public func filterTitle(atIndex: Int) -> String {
        
        return ""
    }
    
    public func set(value: Any, atIndex: Int) -> Bool{
        
        return false
    }
    
    public func filterIsEmpty(atIndex: Int) -> Bool {
        
        return true
    }
    
    public func filterOptions(atIndex: Int) -> [String]? {
        
        return nil
    }
    
    public func filterSelectedOptions(atIndex: Int) -> IndexSet {

        return IndexSet()
    }
}

public class PersonSearchType: SearchType {
    
    enum PersonFilterType: Int {
        case searchType = 0, state, gender, age
    }
    
    private var searchTypeValue: String? = nil
    private var stateValue: [String]? = nil
    private var genderValue: [String]? = nil
    private var ageValue: Range = Range(uncheckedBounds: (0,0))
    public override var numberOfFilters: Int { return 4 }
    public override var title: String { return "Person" }
    
    public override init() {

        super.init()
        
        if let searchTypeArray = filterOptions(atIndex: 0) {
            searchTypeValue = searchTypeArray[0]
        }
    }
    
    public override func filterTitle(atIndex: Int) -> String {
        switch atIndex {
        case PersonFilterType.searchType.rawValue: return "Search Type"
        case PersonFilterType.state.rawValue: return "State/s"
        case PersonFilterType.gender.rawValue: return "Gender/s"
        case PersonFilterType.age.rawValue: return "Age"
        default: return ""
        }
    }
    
    public func filterDefaultText(atIndex: Int) -> String {
        switch atIndex {
        case PersonFilterType.state.rawValue, PersonFilterType.gender.rawValue, PersonFilterType.age.rawValue: return "All"
        default: return ""
        }
    }
    
    public override func filterValue(atIndex: Int) -> String {
        
        var valueText : String = ""
        
        switch atIndex {
        case PersonFilterType.searchType.rawValue:
            if let stringValue = searchTypeValue {
                valueText = stringValue
            } else {
                valueText = filterDefaultText(atIndex: atIndex)
            }
            break
        case PersonFilterType.state.rawValue:
            if let stringArray = stateValue {
                valueText = stringArray.joined(separator: ", ")
            } else {
                valueText = filterDefaultText(atIndex: atIndex)
            }
            break
        case PersonFilterType.gender.rawValue:
            if let stringArray = genderValue {
                valueText = stringArray.joined(separator: ", ")
            } else {
                valueText = filterDefaultText(atIndex: atIndex)
            }
            break
        case PersonFilterType.age.rawValue:
            if ageValue.lowerBound == 0 && ageValue.upperBound == 0 {
                valueText = filterDefaultText(atIndex: atIndex)
            } else {
                valueText = "\(ageValue.lowerBound) - \(ageValue.upperBound)"
            }
            break
        default:
            break
        }
        
        return valueText
    }
    
    public override func set(value: Any, atIndex: Int) -> Bool {
        switch atIndex {
        case PersonFilterType.searchType.rawValue:
            if let stringValue = value as? String {
                searchTypeValue = stringValue
                return true
            }
            break
        case PersonFilterType.state.rawValue:
            if let stringArray = value as? [String] {
                if stringArray.isEmpty { stateValue = nil } else { stateValue = stringArray }
                return true
            }
            break
        case PersonFilterType.gender.rawValue:
            if let stringArray = value as? [String] {
                if stringArray.isEmpty { genderValue = nil } else { genderValue = stringArray }
                return true
            }
            break
        case PersonFilterType.age.rawValue:
            if let newRange = value as? Range<Int> {
                ageValue = newRange
                return true
            }
            break
        default:
            break
        }
        
        return false
    }
    
    public override func filterIsEmpty(atIndex: Int) -> Bool {
        switch atIndex {
        case PersonFilterType.searchType.rawValue:
            return searchTypeValue == nil
        case PersonFilterType.state.rawValue:
            return stateValue == nil
        case PersonFilterType.gender.rawValue:
            return genderValue == nil
        case PersonFilterType.age.rawValue:
            return ageValue.isEmpty
        default:
            
            break
        }
        
        return true
    }
    
    public override func filterOptions(atIndex: Int) -> [String]? {
        
        // TODO: Tie in with manifest items Currently using test data
        switch atIndex {
        case PersonFilterType.searchType.rawValue:
            return ["Name", "License", "Address"]
        case PersonFilterType.state.rawValue:
            return ["VIC", "NSW", "QLD", "WA", "TAS", "ACT", "NT", "SA"]
        case PersonFilterType.gender.rawValue:
            return ["Male", "Female", "Other"]
        case PersonFilterType.age.rawValue:
            return  nil
        default:
            break
        }
        
        return nil
    }
    
    public override func filterSelectedOptions(atIndex: Int) -> IndexSet {
        var selectedIndexes = IndexSet()
        if let options = filterOptions(atIndex: atIndex) {
            
            switch atIndex {
            case PersonFilterType.searchType.rawValue:
                if let selectedIndex = options.index(of: filterValue(atIndex: atIndex)) {
                    selectedIndexes.insert(selectedIndex)
                }
                break
            case PersonFilterType.state.rawValue:
                if let values = stateValue {
                    for value in values {
                        if let selectedIndex = options.index(of: value) {
                            selectedIndexes.insert(selectedIndex)
                        }
                    }
                }
                break
            case PersonFilterType.gender.rawValue:
                if let values = genderValue {
                    for value in values {
                        if let selectedIndex = options.index(of: value) {
                            selectedIndexes.insert(selectedIndex)
                        }
                    }
                }
                break
            case PersonFilterType.age.rawValue: // Assuming 0 is minumum
                let minValue = ageValue.lowerBound
                let maxValue = ageValue.upperBound
                
                selectedIndexes.insert(minValue)
                selectedIndexes.insert(maxValue)
                break
            default:
                break
            }
        }
        
        return selectedIndexes
    }
}

public class VehicleSearchType: SearchType {
    
    enum VehicleFilterType: Int {
        case searchType = 0, state, make, model
    }
    
    private var searchTypeValue: String? = nil
    private var stateValue: [String]? = nil
    private var makeValue: [String]? = nil
    private var modelValue: [String]? = nil
    public override var numberOfFilters: Int { return 4 }
    public override var title: String { return "Vehicle" }
    
    public override init() {
        super.init()
        
        if let searchTypeArray = filterOptions(atIndex: 0) {
            searchTypeValue = searchTypeArray[0]
        }
    }
    
    public override func filterTitle(atIndex: Int) -> String {
        switch atIndex {
        case VehicleFilterType.searchType.rawValue: return "Search Type"
        case VehicleFilterType.state.rawValue: return "State/s"
        case VehicleFilterType.make.rawValue: return "Make"
        case VehicleFilterType.model.rawValue: return "Model"
        default: return ""
        }
    }
    
    public func filterDefaultText(atIndex: Int) -> String {
        switch atIndex {
        case VehicleFilterType.state.rawValue, VehicleFilterType.make.rawValue, VehicleFilterType.model.rawValue: return "All"
        default: return ""
        }
    }
    
    public override func filterValue(atIndex: Int) -> String {
        
        var valueText : String = ""
        
        switch atIndex {
        case VehicleFilterType.searchType.rawValue:
            if let stringValue = searchTypeValue {
                valueText = stringValue
            } else {
                valueText = filterDefaultText(atIndex: atIndex)
            }
            break
        case VehicleFilterType.state.rawValue:
            if let stringArray = stateValue {
                valueText = stringArray.joined(separator: ", ")
            } else {
                valueText = filterDefaultText(atIndex: atIndex)
            }
            break
        case VehicleFilterType.make.rawValue:
            if let stringArray = makeValue {
                valueText = stringArray.joined(separator: ", ")
            } else {
                valueText = filterDefaultText(atIndex: atIndex)
            }
            break
        case VehicleFilterType.model.rawValue:
            if let stringArray = modelValue {
                valueText = stringArray.joined(separator: ", ")
            } else {
                valueText = filterDefaultText(atIndex: atIndex)
            }
            break
        default:
            break
        }
        
        return valueText
    }
    
    public override func set(value: Any, atIndex: Int) -> Bool {
        switch atIndex {
        case VehicleFilterType.searchType.rawValue:
            if let stringValue = value as? String {
                searchTypeValue = stringValue
                return true
            }
            break
        case VehicleFilterType.state.rawValue:
            if let stringArray = value as? [String] {
                if stringArray.isEmpty { stateValue = nil } else { stateValue = stringArray }
                return true
            }
            break
        case VehicleFilterType.make.rawValue:
            if let stringArray = value as? [String] {
                if stringArray.isEmpty { makeValue = nil } else { makeValue = stringArray }
                return true
            }
            break
        case VehicleFilterType.model.rawValue:
            if let stringArray = value as? [String] {
                if stringArray.isEmpty { modelValue = nil } else { modelValue = stringArray }
                return true
            }
            break
        default:
            break
        }
        
        return false
    }
    
    public override func filterIsEmpty(atIndex: Int) -> Bool {
        switch atIndex {
        case VehicleFilterType.searchType.rawValue:
            return searchTypeValue == nil
        case VehicleFilterType.state.rawValue:
            return stateValue == nil
        case VehicleFilterType.make.rawValue:
            return makeValue == nil
        case VehicleFilterType.model.rawValue:
            return modelValue == nil
        default:
            break
        }
        
        return true
    }

    public override func filterOptions(atIndex: Int) -> [String]? {
        
        // TODO: Tie in with manifest items Currently using test data
        switch atIndex {
        case VehicleFilterType.searchType.rawValue:
            return ["Vehicle Registration", "VIN"]
        case VehicleFilterType.state.rawValue:
            return ["VIC", "NSW", "QLD", "WA", "TAS", "ACT", "NT", "SA"]
        case VehicleFilterType.make.rawValue:
            return ["Mazda", "Toyota", "BMW"]
        case VehicleFilterType.model.rawValue:
            // Model will need to be a dependancy of Make
            return []
        default:
            break
        }
        
        return nil
    }
    
    public override func filterSelectedOptions(atIndex: Int) -> IndexSet {
        var selectedIndexes = IndexSet()
        if let options = filterOptions(atIndex: atIndex) {
            
            switch atIndex {
            case VehicleFilterType.searchType.rawValue:
                if let selectedIndex = options.index(of: filterValue(atIndex: atIndex)) {
                    selectedIndexes.insert(selectedIndex)
                }
                break
            case VehicleFilterType.state.rawValue:
                if let values = stateValue {
                    for value in values {
                        if let selectedIndex = options.index(of: value) {
                            selectedIndexes.insert(selectedIndex)
                        }
                    }
                }
                break
            case VehicleFilterType.make.rawValue:
                if let values = makeValue {
                    for value in values {
                        if let selectedIndex = options.index(of: value) {
                            selectedIndexes.insert(selectedIndex)
                        }
                    }
                }
                break
            case VehicleFilterType.model.rawValue:
                if let values = modelValue {
                    for value in values {
                        if let selectedIndex = options.index(of: value) {
                            selectedIndexes.insert(selectedIndex)
                        }
                    }
                }
                break
            default:
                break
            }
        }
        
        return selectedIndexes
    }
}

public class OrganizationSearchType: SearchType {
    
    public override var title: String { return "Organisation" }
    
    public override init() {
        super.init()
    }
    
    public override func filterTitle(atIndex: Int) -> String {
        switch atIndex {

        default: return ""
        }
    }
    
    public func filterDefaultText(atIndex: Int) -> String {
        switch atIndex {

        default: return ""
        }
    }
    
    public override func filterValue(atIndex: Int) -> String {
        
        var valueText : String = ""
        
        switch atIndex {
        
        default:
            break
        }
        
        return valueText
    }
    
    public override func set(value: Any, atIndex: Int) -> Bool {
        switch atIndex {
        
        default:
            break
        }
        
        return false
    }
}

public class LocationSearchType: SearchType {
    
    public override var title: String { return "Location" }
    
    public override init() {
        super.init()
    }
}

public class PopoverSelectableTableViewController : UITableViewController {
    
    let cellIdentifier = "DefaultTableViewCellIdentifier"
    let cellHeight: CGFloat = 40.0
    
    var hasMultipleSections: Bool {
        if mustHaveValue == false && defaultValue != nil {
            return true
        }
        
        return false
    }
    
    public var linkedSegmentAndIndex: IndexPath? = nil
    public var defaultValue: String? = nil
    public var mustHaveValue: Bool = false
    
    public var canMultiSelect: Bool = false {
        didSet {
            // What do you do here if you disable multiple selection and selectedItemsIndex contains multiple? Something to think about...
            
            if isViewLoaded {
                tableView.allowsMultipleSelection = canMultiSelect
            }
        }
    }
    public var sourceItems: [String]? = []
    
    weak var popoverTableViewDelegate: PopoverTableViewDelegate?
    
    public var selectedItemsIndex: IndexSet = IndexSet() {
        didSet {
            if selectedItemsIndex == oldValue || isViewLoaded == false || isSelectionChangeFromUserInteraction {
                if popoverTableViewDelegate != nil && isSelectionChangeFromUserInteraction {
                    popoverTableViewDelegate?.popoverTableSelectionChanged(self, newValues: selectedItemsIndex)
                }
                
                if selectedItemsIndex.count == 0 && hasMultipleSections == true {
                    tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                }
                
                return
            }
            
            var newSelectedIndexPaths = Set(selectedItemsIndex.map({ IndexPath(row: $0, section: 0)}))
            
            let currentlySelectedIndexPaths = tableView.indexPathsForVisibleRows ?? []
            
            // for all that are currently selected that shouldn't be, remove them
            for indexPath in currentlySelectedIndexPaths where newSelectedIndexPaths.contains(indexPath) == false {
                tableView.deselectRow(at: indexPath, animated: false)
            }
            
            // remove all the currently selected ones to work out which ones should be selected
            newSelectedIndexPaths.subtract(currentlySelectedIndexPaths)
            
            // select all left over
            for indexPath in newSelectedIndexPaths {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    private var isSelectionChangeFromUserInteraction = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = canMultiSelect
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        // do this to force the first layout so we can get the size.
        tableView.layoutIfNeeded()
        
        // Set this now, so that the popover automatically retains the correct height,
        // rather than later in a KVO notification after it forces your table view to be a standard size
        preferredContentSize = CGSize(width: 320.0, height: tableView.contentSize.height)
        
        
        if selectedItemsIndex.count == 0 && hasMultipleSections == true {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        }
        
        for index in selectedItemsIndex {
            var section = 0
            
            if hasMultipleSections {
                section = 1
            }
            tableView.selectRow(at: IndexPath(row: index, section: section), animated: false, scrollPosition: .none)
        }
        
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
    }
    
    deinit {
        
        if isViewLoaded {
            tableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &kvoContext)
        }
    }
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
        
        clearsSelectionOnViewWillAppear = false
    }
    
    public init() {
        super.init(style: .plain)
        
        clearsSelectionOnViewWillAppear = false
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if isViewLoaded, let tableView = object as? UITableView, tableView == self.tableView {
                preferredContentSize = CGSize(width: 320.0, height: tableView.contentSize.height)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK - TableviewDatasource
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return hasMultipleSections == true ? 2 : 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasMultipleSections == true && section == 0 {
            return 1
        }
        
        return sourceItems?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if mustHaveValue == false && indexPath.section == 0 {
            cell.textLabel?.text = defaultValue ?? "No value"
        } else {
            cell.textLabel?.text = sourceItems?[indexPath.row]
        }
        
        return cell
    }
    
    
    // MARK - TableViewDelegate
    public override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print ("Will select row")
        
        let row = indexPath.row
        
        if mustHaveValue == true && selectedItemsIndex.contains(row) == true {
            if selectedItemsIndex.count == 1 {
                return nil
            }
        }
        
        return indexPath
    }
    
    public override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        print ("Will deselect row")
        
        let row = indexPath.row
        
        if hasMultipleSections && indexPath.section == 0{
            return nil
        }
        
        if mustHaveValue == true && selectedItemsIndex.contains(row) == true && canMultiSelect == true {
            if selectedItemsIndex.count == 1 {
                return nil
            }
        }
        
        return indexPath
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Did Select Row")
        
        // Set this temporarily to block unnecessary work. The selection has already occurred in UI
        isSelectionChangeFromUserInteraction = true
        
        if hasMultipleSections {
            if indexPath.section == 0 {
                // Deselect all

                if selectedItemsIndex.count < 1 { return }
                
                for index in selectedItemsIndex {
                    tableView.deselectRow(at: IndexPath(row: index, section:1), animated: false)
                }
                selectedItemsIndex.removeAll()
                
                isSelectionChangeFromUserInteraction = false
                return
            } else {
                tableView.deselectRow(at: IndexPath(row:0, section:0), animated: false)
            }
        }
        
        if canMultiSelect {
            selectedItemsIndex.insert(indexPath.row)
        } else {
            if selectedItemsIndex.contains(indexPath.row) {
                selectedItemsIndex.remove(indexPath.row)
                tableView.deselectRow(at: indexPath, animated: false)
            } else {
                selectedItemsIndex = IndexSet(integer: indexPath.row)
            }
        }
        
        isSelectionChangeFromUserInteraction = false
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Did deselect row")
        
        if hasMultipleSections == true && canMultiSelect == true { isSelectionChangeFromUserInteraction = true }

        let row = indexPath.row
        
        if selectedItemsIndex.contains(row) {
            selectedItemsIndex.remove(row)
            print("Contains element: Removing:\(row)")
        }
        
        isSelectionChangeFromUserInteraction = false
    }
}

// MARK - PopoverTableView delegate
@objc protocol PopoverTableViewDelegate: class {
    
    @objc optional func popoverTableDidCancel(_ tableView: PopoverSelectableTableViewController)

    func popoverTableSelectionChanged(_ tableView: PopoverSelectableTableViewController, newValues: IndexSet)
}
