//
//  PersonCriminalHistoryViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// A view controller for presenting a person's criminal history.
open class PersonCriminalHistoryViewController: EntityDetailCollectionViewController, FilterViewControllerDelegate {
    
    // Probably refactor sorting and date sorting into a more general sorting?
    public enum Sorting: Pickable {
        case dateNewest
        case dateOldest
        case title
        
        func compare(_ h1: CriminalHistory, _ h2: CriminalHistory) -> Bool {
            switch self {
            case .dateNewest:
                return DateSorting.newest.compare(h1.lastOccurred ?? .distantPast, h2.lastOccurred ?? .distantPast)
            case .dateOldest:
                return DateSorting.oldest.compare(h1.lastOccurred ?? .distantPast, h2.lastOccurred ?? .distantPast)
            case .title:
                if let h2Title = h2.offenceDescription {
                    return h1.offenceDescription?.localizedStandardCompare(h2Title) == .orderedAscending
                }
                return h1.offenceDescription != nil
            }
        }
        
        public var title: String? {
            switch self {
            case .dateNewest: return NSLocalizedString("Newest", comment: "")
            case .dateOldest: return NSLocalizedString("Oldest", comment: "")
            case .title: return NSLocalizedString("Title", comment: "")
            }
        }
        
        public var subtitle: String? {
            return nil
        }
        
        static let allCases: [Sorting] = [.dateNewest, .dateOldest, .title]
    }
    
    
    // MARK: - Public Properties
    
    open override var entity: Entity? {
        get {
            return viewModel.person
        }
        set {
            viewModel.person = newValue as? Person
            reloadSections()
        }
    }
    
    // MARK: - Private properties
    
    private lazy var viewModel: PersonCriminalHistoryViewModel = {
        var vm = PersonCriminalHistoryViewModel()
        vm.delegate = self
        return vm
    }()
    
    
    fileprivate let filterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
    
    fileprivate var filterDateRange: FilterDateRange?
    
    fileprivate var sorting: Sorting = .dateNewest
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        
        loadingManager.state = .noContent
        
        title = NSLocalizedString("Criminal History", comment: "")
        
        sidebarItem.image = AssetManager.shared.image(forKey: .list)
        
        filterBarButtonItem.target = self
        filterBarButtonItem.action = #selector(filterItemDidSelect(_:))
        navigationItem.rightBarButtonItem = filterBarButtonItem
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingManager.noContentView.titleLabel.text = NSLocalizedString("No Criminal History Found", bundle: .mpolKit, comment: "")
        updateNoContentDetails(title: viewModel.noContentTitle(), subtitle: viewModel.noContentSubtitle())
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)
        
        let cellInfo = viewModel.cellInfo(for: indexPath)
        
        cell.titleLabel.text = cellInfo.title
        cell.subtitleLabel.text = cellInfo.subtitle
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            
            header.text = viewModel.sectionHeader
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {

        let cellInfo = viewModel.cellInfo(for: indexPath)
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: cellInfo.title, subtitle: cellInfo.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    
    // MARK: - FilterViewControllerDelegate
    
    public func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)
        
        if applyingChanges == false {
            return
        }
        
        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is Sorting:
                self.sorting = filterList.options[filterList.selectedIndexes].first as? Sorting ?? self.sorting
            case let dateRange as FilterDateRange:
                if dateRange.startDate == nil && dateRange.endDate == nil {
                    self.filterDateRange = nil
                } else {
                    self.filterDateRange = dateRange
                }
            default:
                break
            }
        }
        
        reloadSections()
    }
    
    
    // MARK: - Private methods
    
    @objc private func filterItemDidSelect(_ item: UIBarButtonItem) {
        let sortingOptions = Sorting.allCases
        
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        
        let filterTypes = FilterList(title: NSLocalizedString("Sort By", comment: ""), displayStyle: .list, options: sortingOptions, selectedIndexes: sortingOptions.indexes(where: { self.sorting == $0 }))
        
        let filterVC = FilterViewController(options: [dateRange, filterTypes])
        filterVC.title = NSLocalizedString("Filter Actions", comment: "")
        filterVC.delegate = self
        let navController = PopoverNavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .popover
        if let popoverPresentationController = navController.popoverPresentationController {
            popoverPresentationController.barButtonItem = item
        }
        
        present(navController, animated: true)
    }
    
    private func reloadSections() {
        var filters: [FilterDescriptor<CriminalHistory>] = []
        if let dateRange = self.filterDateRange {
            filters.append(FilterRangeDescriptor<CriminalHistory, Date>(key: { $0.lastOccurred }, start: dateRange.startDate, end: dateRange.endDate))
        }
        
        let sort: SortDescriptor<CriminalHistory>
        switch self.sorting {
        case .dateNewest, .dateOldest:
            sort = SortDescriptor<CriminalHistory>(ascending: self.sorting == .dateOldest) { $0.lastOccurred }
        case .title:
            sort = SortDescriptor<CriminalHistory>(ascending: true) { $0.offenceDescription }
        }
        
        viewModel.reloadSections(withFilterDescriptors: filters, sortDescriptors: [sort])
    }
}


extension PersonCriminalHistoryViewController: EntityDetailViewModelDelegate {
    
    public func updateSidebarItemCount(_ count: UInt) {
        sidebarItem.count = count
    }
    
    public func updateNoContentDetails(title: String?, subtitle: String? = nil) {
        loadingManager.noContentView.titleLabel.text = title
        loadingManager.noContentView.subtitleLabel.text = subtitle
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
    
    public func updateFilterBarButtonItemActivity() {
        filterBarButtonItem.isActive = sorting != .dateNewest || filterDateRange != nil
    }
    
    public func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
}

