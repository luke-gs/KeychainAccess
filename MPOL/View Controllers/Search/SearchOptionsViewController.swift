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

class SearchOptionsViewController: FormCollectionViewController {
    
    let dataSources: [SearchDataSource]
    
    var selectedDataSourceIndex: Int = 0 {
        didSet {
            if selectedDataSourceIndex == oldValue { return }
            
            if selectedDataSourceIndex >= dataSources.count {
                fatalError("SearchOptionsViewController.selectedDataSourceIndex set to an invalid index. Index must be lower than the count of data sources.")
            }
            
            selectedDataSource = dataSources[selectedDataSourceIndex]
        }
    }
    
    private(set) var areFiltersHidden: Bool = true {
        didSet {
            if areFiltersHidden == oldValue { return }
            
            reloadCollectionViewRetainingEditing()
        }
    }
    
    private var selectedDataSource: SearchDataSource {
        didSet {
            reloadCollectionViewRetainingEditing()
        }
    }
    
    private var isEditingTextField: Bool = false
    
    
    // MARK: - Initializers
    
    init(dataSources: [SearchDataSource] = [PersonSearchDataSource(), VehicleSearchDataSource(), OrganizationSearchDataSource(), LocationSearchDataSource()]) {
        guard let firstDataSource = dataSources.first else {
            fatalError("SearchOptionsViewController requires at least one available search type")
        }
        
        self.dataSources        = dataSources
        self.selectedDataSource = firstDataSource
        
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        collectionView?.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
    }
    
    
    // MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.layer.presentation()
        
        collectionView.register(SearchFieldCollectionViewCell.self)
        collectionView.register(SegmentedControlCollectionViewCell.self)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.alwaysBounceVertical = false
        
        collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), context: &kvoContext)
        preferredContentSize = collectionView.contentSize
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isEditingTextField {
            beginEditingSearchField()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        endEditingSearchField(changingState: false)
        super.viewWillDisappear(animated)
    }
    
    private func reloadCollectionViewRetainingEditing() {
        guard let collectionView = self.collectionView else { return }
        
        let wasSearchFieldActive = self.searchFieldCell?.textField.isFirstResponder ?? false
        
        collectionView.reloadData()
        
        if wasSearchFieldActive {
            beginEditingSearchField()
        }
    }
    
    
    // MARK: - Editing
    
    func beginEditingSearchField() {
        collectionView?.selectItem(at: indexPathForSearchFieldCell, animated: false, scrollPosition: [])
        searchFieldCell?.textField.becomeFirstResponder()
        isEditingTextField = true
    }
    
    func endEditingSearchField() {        
        endEditingSearchField(changingState: true)
    }
    
    private func endEditingSearchField(changingState: Bool) {
        collectionView?.deselectItem(at: indexPathForSearchFieldCell, animated: false)
        searchFieldCell?.textField.resignFirstResponder()
        if changingState {
            isEditingTextField = false
        }
    }
    
    private var searchFieldCell: SearchFieldCollectionViewCell? {
        collectionView?.layoutIfNeeded()
        return collectionView?.cellForItem(at: indexPathForSearchFieldCell) as? SearchFieldCollectionViewCell
    }
    
    private var indexPathForSearchFieldCell: IndexPath {
        return IndexPath(item: 1, section: 0)
    }
    
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if let collectionView = object as? UICollectionView, collectionView == self.collectionView {
                preferredContentSize = collectionView.contentSize
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return selectedDataSource.numberOfFilters > 0 ? 2 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // This we should force unwrap because if we get the wrong section count here,
        // it's a fatal error anyway and we've seriously ruined our logic.
        switch Section(rawValue: section)! {
        case .generalDetails: return 2
        case .filters:        return selectedDataSource.numberOfFilters
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .generalDetails:
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(of: SegmentedControlCollectionViewCell.self, for: indexPath)
                let segmentedControl = cell.segmentedControl
                if segmentedControl.numberOfSegments == 0 {
                    for (index, source) in dataSources.enumerated() {
                        segmentedControl.insertSegment(withTitle: source.localizedDisplayName, at: index, animated: false)
                    }
                    segmentedControl.addTarget(self, action: #selector(searchTypeSegmentedControlValueDidChange(_:)), for: .valueChanged)
                }
                
                segmentedControl.selectedSegmentIndex = dataSources.index(where: { $0 == selectedDataSource }) ?? UISegmentedControlNoSegment
                
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
            let dataSource = self.selectedDataSource
            
            filterCell.titleLabel.text = dataSource.titleForFilter(at: filterIndex)
            if let value = dataSource.valueForFilter(at: filterIndex) {
                filterCell.subtitleLabel.text  = value
                filterCell.subtitleLabel.alpha = 1.0
            } else {
                filterCell.subtitleLabel.text  = dataSource.defaultValueForFilter(at: filterIndex)
                filterCell.subtitleLabel.alpha = 0.3
            }
            
            return filterCell
        }
    }
    
    // MARK: - CollectionView Delegates
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        func cancelSelection() {
            collectionView.deselectItem(at: indexPath, animated: false)
            
            if isEditingTextField {
                // Workaround:
                // Calling this without dispatch async gets deselected *after* this call.
                // Async it to get after this turn of the run loop.
                DispatchQueue.main.async {
                    self.beginEditingSearchField()
                }
            }
        }
        
        switch Section(rawValue: indexPath.section)! {
        case .generalDetails:
            // TODO: Handle the general details case.
            
            if indexPath.item == 1 {
                beginEditingSearchField()
            } else {
                cancelSelection()
            }
        case .filters:
            
            // If there's no update view controller, we don't want to do anything.
            // Quickly deselect the index path, and return out.
            guard let updateViewController = selectedDataSource.updateController(forFilterAt: indexPath.item) else {
                cancelSelection()
                return
            }
            
            // stop editing the field, if it is currently editing.
            if isEditingTextField {
                endEditingSearchField()
            }
            
            updateViewController.modalPresentationStyle = .popover
            if let popoverPresentationController = updateViewController.popoverPresentationController,
                let cell = collectionView.cellForItem(at: indexPath) {
                popoverPresentationController.sourceView = cell
                popoverPresentationController.sourceRect = cell.bounds
            }
            
            if let popoverNavigationController = updateViewController as? PopoverNavigationController {
                let dataSourceSpecifiedDismissHandler = popoverNavigationController.dismissHandler
                popoverNavigationController.dismissHandler = { [weak self] (animated: Bool) in
                    dataSourceSpecifiedDismissHandler?(animated)
                    self?.collectionView?.deselectItem(at: indexPath, animated: animated)
                }
            }
            
            present(updateViewController, animated: true)
        }
    }
    
    // MARK: - CollectionViewDelegate MPOLLayout Methods
    
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalFooterInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 32.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return Section(rawValue: section) == .generalDetails ? 0.0 : CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        
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
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        switch Section(rawValue: indexPath.section)! {
        case .generalDetails:
            return SearchFieldCollectionViewCell.cellContentHeight
        case .filters:
            
            let filterIndex = indexPath.item
            let title    = selectedDataSource.titleForFilter(at: filterIndex)
            let subtitle = selectedDataSource.valueForFilter(at: filterIndex) ?? selectedDataSource.defaultValueForFilter(at: filterIndex)
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, emphasis: .subtitle, singleLineSubtitle: true)
        }
        
    }
    
    
    
    private enum Section: Int {
        case generalDetails, filters
    }
    
    @objc private func searchTypeSegmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
        let index = segmentedControl.selectedSegmentIndex
        if index == UISegmentedControlNoSegment { return }
        
        selectedDataSourceIndex = index
    }
    
}
