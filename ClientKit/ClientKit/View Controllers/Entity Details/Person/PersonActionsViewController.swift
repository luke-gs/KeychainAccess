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
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet {
            sidebarItem.count = UInt(person?.actions?.count ?? 0)
            updateNoContentSubtitle()
            reloadSections()
        }
    }
    
    private var actions: [Action] = [] {
        didSet {
            hasContent = actions.isEmpty == false
            collectionView?.reloadData()
        }
    }
    
    private let filterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
    
    private var filterTypes: Set<String>?
    
    private var filterDateRange: FilterDateRange?
    
    
    public override init() {
        super.init()
        
        hasContent = false
        
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
        
        noContentTitleLabel?.text = NSLocalizedString("No Actions Found", bundle: .mpolKit, comment: "")
        updateNoContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return actions.isEmpty ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        let action = actions[indexPath.item]
        cell.titleLabel.text = action.type?.title ?? NSLocalizedString("Action (Unknown Type)", bundle: .mpolKit, comment: "")
        if let date = action.date {
            cell.subtitleLabel.text = DateFormatter.shortDate.string(from: date)
        } else {
            cell.subtitleLabel.text = NSLocalizedString("Date unknown", bundle: .mpolKit, comment: "") // TODO
        }
        
        cell.detailLabel.text = nil
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            
            // TODO: Refactor for StringsDict pluralization
            let actionCount = actions.count
            if actionCount > 0 {
                let baseString = actionCount > 1 ? NSLocalizedString("%d ACTIONS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ACTION", bundle: .mpolKit, comment: "")
                header.text = String(format: baseString, actionCount)
            } else {
                header.text = nil
            }
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
        var allTypes = Set<String>()
        person?.actions?.forEach {
            if let type = $0.type {
                allTypes.insert(type)
            }
        }
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
    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        if person?.actions?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = entity {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            label.text = String(format: NSLocalizedString("This %@ has no actions", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            label.text = NSLocalizedString("This filter has no matching actions", comment: "")
        }
    }
    
    private func reloadSections() {
        var actions = person?.actions ?? []
        
        let selectActionTypes = self.filterTypes != nil
        let requiresFiltering: Bool = selectActionTypes || filterDateRange != nil
        
        if requiresFiltering {
            actions = actions.filter { action in
                if selectActionTypes {
                    guard let type = action.type, self.filterTypes!.contains(type) else {
                        return false
                    }
                }
                if let filteredDateRange = self.filterDateRange {
                    guard let date = action.date, filteredDateRange.contains(date) else {
                        return false
                    }
                }
                
                return true
            }
        }
        
        self.actions = actions
        
        filterBarButtonItem.isActive = requiresFiltering
    }
    
}
