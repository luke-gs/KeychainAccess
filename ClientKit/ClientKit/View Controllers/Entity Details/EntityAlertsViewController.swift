//
//  EntityAlertsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class EntityAlertsViewController: EntityDetailCollectionViewController, FilterViewControllerDelegate {
    
    
    // MARK: - Public Properties
    
    open override var entity: Entity? {
        didSet {
            viewModel.entity = entity
            reloadSections()
        }
    }
    
    
    // MARK: - Private properties
    
    private lazy var viewModel: EntityAlertsViewModel = {
        var vm = EntityAlertsViewModel()
        vm.delegate = self
        return vm
    }()
    
    
    fileprivate let filterBarButtonItem: FilterBarButtonItem
    
    fileprivate var filteredAlertLevels: Set<Alert.Level> = Set(Alert.Level.allCases)
    
    fileprivate var filterDateRange: FilterDateRange?
    
    fileprivate var dateSorting: DateSorting = .newest
    
    // MARK: - Initializers
    
    public override init() {
        filterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
        
        super.init()
        title = NSLocalizedString("Alerts", bundle: .mpolKit, comment: "")
        
        sidebarItem.image = AssetManager.shared.image(forKey: .alert)
        
        filterBarButtonItem.target = self
        filterBarButtonItem.action = #selector(filterItemDidSelect(_:))
        navigationItem.rightBarButtonItem = filterBarButtonItem
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingManager.noContentView.titleLabel.text = NSLocalizedString("No Alerts Found", bundle: .mpolKit, comment: "")
        updateNoContentSubtitle(viewModel.noContentSubtitle())
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)

        let cellInfo = viewModel.cellInfo(for: indexPath)
        
        cell.imageView.image    = cellInfo.image
        cell.titleLabel.text    = cellInfo.title
        cell.detailLabel.text   = cellInfo.detail
        cell.subtitleLabel.text = cellInfo.subtitle
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            
            let alerts = viewModel.item(at: indexPath.section)!
            header.text = viewModel.headerText(for: alerts)
            
            if alerts.count > 0 {
                header.showsExpandArrow = true
                
                header.tapHandler = { [weak self] (headerView, indexPath) in
                    guard let `self` = self else { return }
                    self.viewModel.updateCollapsedSections(for: alerts)
                    self.collectionView?.reloadData()
                }
                header.isExpanded = viewModel.isExpanded(for: alerts)
            }
            
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormDetailCell.minimumContentHeight(withImageSize: UIImage.statusDotFrameSize, compatibleWith: traitCollection)
    }
    
    
    // MARK: - Filter view controller delegate
    
    open func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)
        
        if applyingChanges == false {
            return
        }
        
        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is Alert.Level:
                self.filteredAlertLevels = Set((filterList.options as! [Alert.Level])[filterList.selectedIndexes])
            case let filterList as FilterList where filterList.options.first is DateSorting:
                guard let selectedIndex = filterList.selectedIndexes.first else {
                    self.dateSorting = .newest
                    return
                }
                self.dateSorting = filterList.options[selectedIndex] as! DateSorting
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
        let alertLevels: [Alert.Level] = [.high, .medium, .low]
        
        let filterLevels = FilterList(title: NSLocalizedString("Alert Types", comment: ""), displayStyle: .checkbox, options: alertLevels, selectedIndexes: alertLevels.indexes(where: { filteredAlertLevels.contains($0) }))
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        let sorting = FilterList(title: "Sort By", displayStyle: .list, options: DateSorting.allCases, selectedIndexes: [DateSorting.allCases.index(of: dateSorting) ?? 0])
        
        let filterVC = FilterViewController(options: [filterLevels, dateRange, sorting])
        filterVC.title = NSLocalizedString("Filter Alerts", comment: "")
        filterVC.delegate = self
        let navController = PopoverNavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .popover
        if let popoverPresentationController = navController.popoverPresentationController {
            popoverPresentationController.barButtonItem = item
        }
        
        present(navController, animated: true)
    }
    
    private func reloadSections() {
        var filters: [FilterDescriptor<Alert>] = []
        filters.append(FilterValueDescriptor<Alert, Alert.Level>(key: { $0.level }, values: self.filteredAlertLevels))
        
        if let dateRange = self.filterDateRange {
            filters.append(FilterRangeDescriptor<Alert, Date>(key: { $0.effectiveDate }, start: dateRange.startDate, end: dateRange.endDate))
        }
        
        let dateSort = SortDescriptor<Alert>(ascending: dateSorting == .oldest) { $0.effectiveDate }
        
        viewModel.reloadSections(withFilterDescriptors: filters, sortDescriptors: [dateSort])
    }
}


extension EntityAlertsViewController: EntityDetailViewModelDelegate {
    public func updateSidebarItemCount(_ count: UInt) {
        sidebarItem.count = count
    }
    
    public func updateSidebarAlertColor(_ color: UIColor?) {
        sidebarItem.alertColor = color
    }
    
    public func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
    
    public func updateFilterBarButtonItemActivity() {
        let selectAlertLevels = filteredAlertLevels != Set(Alert.Level.allCases)
        let requiresFiltering: Bool = selectAlertLevels || filterDateRange != nil
        
        filterBarButtonItem.isActive = requiresFiltering
    }
    
    public func updateNoContentSubtitle(_ subtitle: String? = nil) {
        loadingManager.noContentView.subtitleLabel.text = subtitle
    }
}

