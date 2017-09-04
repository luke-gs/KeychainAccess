//
//  VehicleOccurrencesViewController.swift
//  ClientKit
//
//  Created by RUI WANG on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

// TEMP stuff
open class VehicleOccurrencesViewController: EntityOccurrencesViewController, FilterViewControllerDelegate {
    
    
    // MARK: - Public properties
    
    open override var entity: Entity? {
        get {
            return viewModel.entity
        }
        set {
            viewModel.entity = newValue
            viewModel.reloadSections(with: filterTypes, filterDateRange: filterDateRange, sortedBy: dateSorting)
        }
    }
    
    
    // MARK: - Private properties
    private lazy var viewModel: VehicleOccurrencesViewModel = {
        var vm = VehicleOccurrencesViewModel()
        vm.delegate = self
        return vm
    }()
    
    fileprivate let filterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
    
    fileprivate var filterTypes: Set<String>?
    
    fileprivate var filterDateRange: FilterDateRange?
    
    fileprivate var dateSorting: DateSorting = .newest

    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        
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

        EventDetailsViewModelRouter.register(eventClass: FieldContact.self, viewModelClass: FieldContactDetailViewModel.self)
        EventDetailsViewModelRouter.register(eventClass: InterventionOrder.self, viewModelClass: InterventionOrderViewModel.self)
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormDetailCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.accessoryView = cell.accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)
        
        let cellInfo = viewModel.cellInfo(for: indexPath)
        
        cell.titleLabel.text    = cellInfo.title
        cell.subtitleLabel.text = cellInfo.subtitle
        cell.detailLabel.text   = cellInfo.detail
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let detailViewController: UIViewController?
        let event = viewModel.item(at: indexPath.item)!
        
        switch event {
        case let fieldContact as FieldContact:
            let fieldContactVC = FieldContactDetailViewController()
            fieldContactVC.event = fieldContact
            detailViewController = fieldContactVC
        case let interventionOrder as InterventionOrder:
            let interventionOrderVC = InterventionOrderDetailViewController()
            interventionOrderVC.event = interventionOrder
            detailViewController = interventionOrderVC
        default:
            detailViewController = nil
        }
        
        guard let detailVC = detailViewController,
            let navController = pushableSplitViewController?.navigationController ?? navigationController else { return }
        
        navController.pushViewController(detailVC, animated: true)
    }
    
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            
            header.text = viewModel.sectionHeader
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormDetailCell.minimumContentHeight(compatibleWith: traitCollection)
    }
    
    
    // MARK: - FilterViewControllerDelegate
    
    public func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        controller.presentingViewController?.dismiss(animated: true)
        
        if applyingChanges == false {
            return
        }
        
        controller.filterOptions.forEach {
            switch $0 {
            case let filterList as FilterList where filterList.options.first is String:
                let selectedIndexes = filterList.selectedIndexes
                let indexCount = selectedIndexes.count
                if indexCount != filterList.options.count {
                    if indexCount == 0 {
                        self.filterTypes = []
                    } else {
                        self.filterTypes = Set(filterList.options[selectedIndexes] as! [String])
                    }
                } else {
                    self.filterTypes = nil
                }
            case let dateRange as FilterDateRange:
                if dateRange.startDate == nil && dateRange.endDate == nil {
                    self.filterDateRange = nil
                } else {
                    self.filterDateRange = dateRange
                }
            case let filterList as FilterList where filterList.options.first is DateSorting:
                guard let selectedIndex = filterList.selectedIndexes.first else {
                    self.dateSorting = .newest
                    return
                }
                self.dateSorting = filterList.options[selectedIndex] as! DateSorting
            default:
                break
            }
        }
        
        viewModel.reloadSections(with: filterTypes, filterDateRange: filterDateRange, sortedBy: dateSorting)
    }
    
    
    // MARK: - Private methods
    
    @objc private func filterItemDidSelect(_ item: UIBarButtonItem) {
        let allTypes = viewModel.allEventTypes
        
        let allSortedTypes = allTypes.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        
        var selectedIndexes: IndexSet
        if let filterTypes = self.filterTypes {
            if filterTypes.isEmpty == false {
                selectedIndexes = allSortedTypes.indexes(where: { filterTypes.contains($0) })
            } else {
                selectedIndexes = IndexSet()
            }
        } else {
            selectedIndexes = IndexSet(integersIn: 0..<allTypes.count)
        }
        
        let filterList = FilterList(title: NSLocalizedString("Events Types", comment: ""), displayStyle: .detailList, options: allSortedTypes, selectedIndexes: selectedIndexes, allowsNoSelection: true, allowsMultipleSelection: true)
        
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        let sorting = FilterList(title: "Sort By", displayStyle: .list, options: DateSorting.allCases, selectedIndexes: [DateSorting.allCases.index(of: dateSorting) ?? 0])
        
        
        let filterVC = FilterViewController(options: [filterList, dateRange, sorting])
        filterVC.title = NSLocalizedString("Filter Events", comment: "")
        filterVC.delegate = self
        let navController = PopoverNavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .popover
        if let popoverPresentationController = navController.popoverPresentationController {
            popoverPresentationController.barButtonItem = item
        }
        
        present(navController, animated: true)
    }
}

extension VehicleOccurrencesViewController: EntityDetailsViewModelDelegate {
    
    public func updateSidebarItemCount(_ count: UInt) {
        sidebarItem.count = count
    }
    
    public func updateNoContentSubtitle(_ subtitle: String? = nil) {
        loadingManager.noContentView.subtitleLabel.text = subtitle
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
    
    public func updateFilterBarButtonItemActivity() {
        let requiresFiltering = filterTypes != nil || filterDateRange != nil
        filterBarButtonItem.isActive = requiresFiltering
    }
    
    public func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
    
}

