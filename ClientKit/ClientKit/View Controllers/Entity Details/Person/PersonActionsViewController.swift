//
//  PersonActionsViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import UIKit
import MPOLKit

// Important: VicPol specific details included. Refactor out at later date.

open class PersonActionsViewController: EntityDetailCollectionViewController, FilterViewControllerDelegate {
    
    
    open override var entity: Entity? {
        get {
            return viewModel.person
        }
        set {
            viewModel.person = newValue as? Person
            reloadSections()
        }
    }
    
    fileprivate let filterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
    
    fileprivate var filterTypes: Set<String>?
    
    fileprivate var filterDateRange: FilterDateRange?
    
    
    private lazy var viewModel: PersonActionsViewModel = {
        var vm = PersonActionsViewModel()
        vm.delegate = self
        return vm
    }()
    
    public override init() {
        super.init()
        
        loadingManager.state = .noContent
        
        title = NSLocalizedString("Actions", comment: "")
        
        sidebarItem.image = AssetManager.shared.image(forKey: .list)
        
        filterBarButtonItem.target = self
        filterBarButtonItem.action = #selector(filterItemDidSelect(_:))
        navigationItem.rightBarButtonItem = filterBarButtonItem
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("PersonActionsViewController does not support NSCoding.")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingManager.noContentView.titleLabel.text = NSLocalizedString("No Actions Found", bundle: .mpolKit, comment: "")
        updateNoContentSubtitle(viewModel.noContentSubtitle())
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.accessoryView  = cell.accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)
        
        let cellInfo = viewModel.cellInfo(for: indexPath)
        
        cell.titleLabel.text    = cellInfo.title
        cell.subtitleLabel.text = cellInfo.subtitle
        cell.detailLabel.text   = cellInfo.detail
        
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
    
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let height = CollectionViewFormDetailCell.minimumContentHeight(withImageSize: UIImage.statusDotFrameSize, compatibleWith: traitCollection)
        
        return height
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
            default:
                break
            }
        }
        
        reloadSections()
    }
    
    
    // MARK: - Private methods
    
    @objc private func filterItemDidSelect(_ item: UIBarButtonItem) {
        let allTypes = viewModel.allActionTypes

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
        
        let filterList = FilterList(title: NSLocalizedString("Action Types", comment: ""), displayStyle: .detailList, options: allSortedTypes, selectedIndexes: selectedIndexes, allowsNoSelection: true, allowsMultipleSelection: true)
        
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        
        let filterVC = FilterViewController(options: [filterList, dateRange])
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
        var filters: [FilterDescriptor<Action>] = []
        
        if let types = self.filterTypes {
            filters.append(FilterValueDescriptor<Action, String>(key: { $0.type }, values: types))
        }
        
        if let dateRange = self.filterDateRange {
            filters.append(FilterRangeDescriptor<Action, Date>(key: { $0.date }, start: dateRange.startDate, end: dateRange.endDate))
        }
        
        viewModel.reloadSections(withFilterDescriptors: filters, sortDescriptors: nil)
    }
    
}

extension PersonActionsViewController: EntityDetailViewModelDelegate {
    
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
        let selectActionTypes = self.filterTypes != nil
        let requiresFiltering: Bool = selectActionTypes || filterDateRange != nil
        
        filterBarButtonItem.isActive = requiresFiltering
    }
    
    public func updateLoadingState(_ state: LoadingStateManager.State) {
        loadingManager.state = state
    }
}

