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

class SearchOptionsViewController: FormCollectionViewController, SearchCollectionViewCellDelegate, PopoverTableViewDelegate {
    
    let availableSearchTypes: [SearchRequest.Type]
    
    var searchRequest: SearchRequest {
        didSet {
            if isViewLoaded {
                reloadCollectionViewRetainingEditing()
            }
        }
    }
    
    private(set) var areFiltersHidden: Bool = true {
        didSet {
            if areFiltersHidden == oldValue { return }
            
            if isViewLoaded {
                reloadCollectionViewRetainingEditing()
            }
        }
    }
    
    
    // MARK: - Initializers
    
    public init(availableSearchTypes: [SearchRequest.Type] = [PersonSearchRequest.self, VehicleSearchRequest.self, OrganizationSearchRequest.self, LocationSearchRequest.self]) {
        guard let firstType = availableSearchTypes.first else {
            fatalError("SearchOptionsViewController requires at least one available search type")
        }
        
        self.availableSearchTypes   = availableSearchTypes
        self.searchRequest          = firstType.init(searchRequest: nil) // Init required explicitly because we're doing a dynamic metatype fetch.
        // TODO: self.searchRequest.delegate = self
        
        super.init()
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
    }
    
    
    // MARK - View Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(SearchFieldCollectionViewCell.self)
        collectionView.register(SegmentedControlCollectionViewCell.self)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.alwaysBounceVertical = false
        
        collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
        preferredContentSize = collectionView.contentSize
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        endEditingSearchField()
        super.viewWillDisappear(animated)
    }
    
    private func reloadCollectionViewRetainingEditing() {
        let wasSearchFieldActive = self.searchFieldCell?.textField.isFirstResponder ?? false
        
        collectionView?.reloadData()
        
        if wasSearchFieldActive {
            beginEditingSearchField()
        }
    }
    
    
    // MARK: - Editing
    
    func beginEditingSearchField() {
        searchFieldCell?.textField.becomeFirstResponder()
    }
    
    func endEditingSearchField() {        
        searchFieldCell?.textField.resignFirstResponder()
    }
    
    private var searchFieldCell: SearchFieldCollectionViewCell? {
        collectionView?.layoutIfNeeded()
        return collectionView?.cellForItem(at: IndexPath(item: 1, section: 0)) as? SearchFieldCollectionViewCell
    }
    
    
    // MARK: - KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if let collectionView = object as? UICollectionView, collectionView == self.collectionView {
                preferredContentSize = collectionView.contentSize
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searchRequest.numberOfFilters > 0 ? 2 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // This we should force unwrap because if we get the wrong section count here,
        // it's a fatal error anyway and we've seriously ruined our logic.
        switch Section(rawValue: section)! {
        case .generalDetails: return 2
        case .filters:        return searchRequest.numberOfFilters
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.text             = "FILTER SEARCH"
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .generalDetails:
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(of: SegmentedControlCollectionViewCell.self, for: indexPath)
                let segmentedControl = cell.segmentedControl
                if segmentedControl.numberOfSegments == 0 {
                    for (index, item) in availableSearchTypes.enumerated() {
                        segmentedControl.insertSegment(withTitle: item.localizedDisplayName, at: index, animated: false)
                    }
                    segmentedControl.addTarget(self, action: #selector(searchTypeSegmentedControlValueDidChange(_:)), for: .valueChanged)
                }
                
                let selectedType = type(of: searchRequest)
                segmentedControl.selectedSegmentIndex = availableSearchTypes.index(where: { $0 == selectedType }) ?? UISegmentedControlNoSegment
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(of: SearchFieldCollectionViewCell.self, for: indexPath)
                
                return cell
            }
        case .filters:
            let filterCell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            filterCell.emphasis = .subtitle
            filterCell.isEditableField = true
            filterCell.subtitleLabel.numberOfLines = 1
            filterCell.selectionStyle = .underline
            filterCell.highlightStyle = .fade
            
            let filterIndex = indexPath.item
            let request = self.searchRequest
            
            filterCell.titleLabel.text     = request.titleForFilter(at: filterIndex)
            if let value = request.valueForFilter(at: filterIndex) {
                filterCell.subtitleLabel.text  = value
                filterCell.subtitleLabel.alpha = 1.0
            } else {
                filterCell.subtitleLabel.text  = request.defaultValueForFilter(at: filterIndex)
                filterCell.subtitleLabel.alpha = 0.3
            }
            
            return filterCell
        }
    }
    
    // MARK: - CollectionView Delegates
    
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch Section(rawValue: indexPath.section)! {
        case .generalDetails:
            // TODO: Handle the general details case.
            
            if indexPath.item == 1 {
                beginEditingSearchField()
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        case .filters:
            
            // If there's no update view controller, we don't want to do anything.
            // Quickly deselect the index path, and return out.
            guard let updateViewController = searchRequest.updateController(forFilterAt: indexPath.item) else {
                collectionView.deselectItem(at: indexPath, animated: false)
                return
            }
            
            // stop editing the field, if it is currently editing.
            endEditingSearchField()
            
            // TODO: present the update view controller.
        }
        
        
//        let index = indexPath.item
//        
//        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? SearchCollectionViewCell {
//            cell.searchTextField.resignFirstResponder()
//        }
//        
//        if indexPath.section == 1 {
//            switch segmentIndex {
//            case SearchSegments.person.rawValue:
//                if let personFilter = searchSources[segmentIndex] as? PersonSearchType {
//                    let tableView = PopoverSelectableTableViewController(style: .plain)
//                    tableView.sourceItems = personFilter.filterOptions(atIndex: index)
//                    tableView.title = personFilter.filterTitle(atIndex: index)
//                    tableView.popoverTableViewDelegate = self
//                    tableView.linkedSegmentAndIndex = IndexPath(item:index, section:segmentIndex)
//                    
//                    switch index {
//                    case PersonSearchType.PersonFilterType.searchType.rawValue:
//                        tableView.mustHaveValue = true
//                        tableView.selectedItemsIndex = personFilter.filterSelectedOptions(atIndex: index)
//                        break
//                    case PersonSearchType.PersonFilterType.state.rawValue:
//                        tableView.defaultValue = personFilter.filterDefaultText(atIndex: index)
//                        tableView.canMultiSelect = true
//                        tableView.selectedItemsIndex = personFilter.filterSelectedOptions(atIndex: index)
//                        break
//                    case PersonSearchType.PersonFilterType.gender.rawValue:
//                        tableView.defaultValue = personFilter.filterDefaultText(atIndex: index)
//                        tableView.canMultiSelect = true
//                        tableView.selectedItemsIndex = personFilter.filterSelectedOptions(atIndex: index)
//                        break
//                    case PersonSearchType.PersonFilterType.age.rawValue:
//                        break
//                    default:
//                        break
//                    }
//                    
//                    let popover = PopoverNavigationController(rootViewController: tableView)
//                    popover.modalPresentationStyle = .popover
//                    
//                    if let presentationController = popover.popoverPresentationController {
//                        
//                        let cell = collectionView.cellForItem(at:indexPath)
//                        
//                        presentationController.sourceView = cell
//                        presentationController.sourceRect = cell!.bounds
//                        
//                    }
//                    
//                    present(popover, animated: true, completion: nil)
//                }
//                break
//            case SearchSegments.vehicle.rawValue:
//                if let vehicleFilter = searchSources[segmentIndex] as? VehicleSearchType {
//                    
//                    let tableView = PopoverSelectableTableViewController(style: .plain)
//                    tableView.sourceItems = vehicleFilter.filterOptions(atIndex: index)
//                    tableView.title = vehicleFilter.filterTitle(atIndex: index)
//                    tableView.popoverTableViewDelegate = self
//                    tableView.linkedSegmentAndIndex = IndexPath(item:index, section:segmentIndex)
//                    
//                    switch index {
//                    case VehicleSearchType.VehicleFilterType.searchType.rawValue:
//                        tableView.mustHaveValue = true
//                        tableView.selectedItemsIndex = vehicleFilter.filterSelectedOptions(atIndex: index)
//                        break
//                    case VehicleSearchType.VehicleFilterType.state.rawValue, VehicleSearchType.VehicleFilterType.make.rawValue, VehicleSearchType.VehicleFilterType.model.rawValue:
//                        tableView.defaultValue = vehicleFilter.filterDefaultText(atIndex: index)
//                        tableView.canMultiSelect = true
//                        tableView.selectedItemsIndex = vehicleFilter.filterSelectedOptions(atIndex: index)
//                        break
//                    default:
//                        break
//                    }
//                    
//                    let popover = PopoverNavigationController(rootViewController: tableView)
//                    popover.modalPresentationStyle = .popover
//                    
//                    if let presentationController = popover.popoverPresentationController {
//                        
//                        let cell = collectionView.cellForItem(at:indexPath)
//                        
//                        presentationController.sourceView = cell
//                        presentationController.sourceRect = cell!.bounds
//                        
//                    }
//                    
//                    present(popover, animated: true, completion: nil)
//                }
//                break
//            case SearchSegments.organisation.rawValue:
//                
//                break
//            default:
//                
//                break
//            }
//        }
    }
    
    // MARK: - CollectionViewDelegate MPOLLayout Methods
    
    
    public func collectionView(_ collectionView: UICollectionView, heightForGlobalFooterInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 32.0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return Section(rawValue: section) == .generalDetails ? 0.0 : CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        
        if indexPath.section == 0 {
            return sectionWidth
        }
        
        let extraLargeText: Bool
        switch traitCollection.preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        
        let minimumWidth: CGFloat = extraLargeText ? 250.0 : 140.0
        let maxColumnCount = 4
        
        return layout.columnContentWidth(forMinimumItemContentWidth: minimumWidth, maximumColumnCount: maxColumnCount, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: UIScreen.main.scale)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        switch Section(rawValue: indexPath.section)! {
        case .generalDetails:
            return SearchFieldCollectionViewCell.cellContentHeight
        case .filters:
            
            let filterIndex = indexPath.item
            let title    = searchRequest.titleForFilter(at: filterIndex)
            let subtitle = searchRequest.valueForFilter(at: filterIndex) ?? searchRequest.defaultValueForFilter(at: filterIndex)
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, emphasis: .subtitle, singleLineSubtitle: true)
        }
        
        
    }
    
    // MARK: - SearchCollectionViewCell Delegates
    
    public func searchCollectionViewCell(_ cell: SearchFieldCollectionViewCell, didChangeText text: String?) {
        areFiltersHidden = text?.isEmpty ?? true == false
        
        if areFiltersHidden && (text?.isEmpty ?? true == false) { // Show filters
            areFiltersHidden = false
            beginEditingSearchField()
        } else if areFiltersHidden == false && (text?.isEmpty ?? true){ // Hide Filters
            areFiltersHidden = true
            beginEditingSearchField()
        }
    }
    
    public func searchCollectionViewCell(_ cell: SearchFieldCollectionViewCell, didSelectSegmentAt index: Int) {
        let selectedType = availableSearchTypes[index]
        if selectedType != type(of: searchRequest) {
            searchRequest = selectedType.init(searchRequest: searchRequest)
        }
    }
    
    // MARK - PopoverTableView Delegate
    func popOverTableSelectionChanged(_ tableView: PopoverSelectableTableViewController, newValues: IndexSet) {
//        print("Value changed")
//        
//        if newValues.count > 0 {
//            for index in newValues {
//                print("Index:\(index)")
//            }
//        }
//        
//        if let segmentAndIndex = tableView.linkedSegmentAndIndex {
//            switch segmentAndIndex.section {
//            case SearchSegments.person.rawValue:
//                if let personFilter = searchSources[segmentIndex] as? PersonSearchType {
//                    switch segmentAndIndex.item {
//                    case PersonSearchType.PersonFilterType.searchType.rawValue:
//                        if let options = tableView.sourceItems {
//                            for index in newValues {
//                                if (personFilter.set(value: options[index], atIndex: segmentAndIndex.item)) {
//                                    collectionView?.reloadData()
//                                }
//                            }
//                        }
//                        break
//                    case PersonSearchType.PersonFilterType.state.rawValue, PersonSearchType.PersonFilterType.gender.rawValue:
//                        if let options = tableView.sourceItems {
//                            var selectedValues: [String] = []
//                            for index in newValues {
//                                selectedValues.append(options[index])
//                            }
//                            
//                            if (personFilter.set(value: selectedValues, atIndex: segmentAndIndex.item)) {
//                                collectionView?.reloadData()
//                            }
//                        }
//                        break
//                    default:
//                        break
//                    }
//                }
//            case SearchSegments.vehicle.rawValue:
//                if let vehicleFilter = searchSources[segmentIndex] as? VehicleSearchType {
//                    switch segmentAndIndex.item {
//                    case VehicleSearchType.VehicleFilterType.searchType.rawValue:
//                        if let options = tableView.sourceItems {
//                            for index in newValues {
//                                if (vehicleFilter.set(value: options[index], atIndex: segmentAndIndex.item)) {
//                                    collectionView?.reloadData()
//                                }
//                            }
//                        }
//                        break
//                    case VehicleSearchType.VehicleFilterType.state.rawValue, VehicleSearchType.VehicleFilterType.make.rawValue, VehicleSearchType.VehicleFilterType.model.rawValue:
//                        if let options = tableView.sourceItems {
//                            var selectedValues: [String] = []
//                            for index in newValues {
//                                selectedValues.append(options[index])
//                            }
//                            
//                            if (vehicleFilter.set(value: selectedValues, atIndex: segmentAndIndex.item)) {
//                                collectionView?.reloadData()
//                            }
//                        }
//                        break
//                    default:
//                        break
//                    }
//                }
//                break
//            default:
//                
//                break
//            }
//        }
    }
    
    private enum Section: Int {
        case generalDetails, filters
    }
    
    @objc private func searchTypeSegmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
        let index = segmentedControl.selectedSegmentIndex
        if index == UISegmentedControlNoSegment { return }
        
        let type = availableSearchTypes[index]
        if type == type(of: searchRequest) { return }
        
        searchRequest = type.init(searchRequest: searchRequest)
    }
    
}

// MARK - Search Type Classes

public class SearchType: NSObject {
    public var title: String { return "" }
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
        case searchType, state, gender, age
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
            if ageValue.isEmpty == true {
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
            return  [] //[0...100]
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
            case PersonFilterType.age.rawValue:
                
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
                    popoverTableViewDelegate?.popOverTableSelectionChanged(self, newValues: selectedItemsIndex)
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
    
    @objc optional func popOverTableDidCancel(_ tableView: PopoverSelectableTableViewController)

    func popOverTableSelectionChanged(_ tableView: PopoverSelectableTableViewController, newValues: IndexSet)
}
