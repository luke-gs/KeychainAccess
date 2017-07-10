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
    
    // TODO: Move onto action types in VicPol
    
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet {
            updateNoContentSubtitle()
            reloadSections()
        }
    }
    
    private var actions: [Action] = [] {
        didSet {
            let actionCount = actions.count
            sidebarItem.count = UInt(actionCount)
            
            if actionCount == 0 && actions.isEmpty == true {
                return
            }
            
            hasContent = actionCount > 0
            collectionView?.reloadData()
        }
    }
    
    private let filterBarButtonItem: UIBarButtonItem
    
    private var filterTypes: Set<Action.ActionType> = Set(Action.ActionType.allCases)
    
    private var filterDateRange: FilterDateRange?
    
    
    public override init() {
        let bundle = Bundle(for: EntityAlertsViewController.self)
        filterBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: bundle, compatibleWith: nil), style: .plain, target: nil, action: nil)
        
        super.init()
        
        hasContent = false
        
        title = NSLocalizedString("Actions", comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconFormFolder",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconFormFolderFilled", in: .mpolKit, compatibleWith: nil)
        
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
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
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
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
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
        return CollectionViewFormExpandingHeaderView.minimumHeight
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
            case let filterList as FilterList where filterList.options.first is Action.ActionType:
                self.filterTypes = Set((filterList.options as! [Action.ActionType])[filterList.selectedIndexes])
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
        let actionTypes = Action.ActionType.allCases
        
        let filterTypes = FilterList(title: NSLocalizedString("Action Types", comment: ""), displayStyle: .detailList, options: actionTypes, selectedIndexes: actionTypes.indexes(where: { self.filterTypes.contains($0) }), allowsNoSelection: true, allowsMultipleSelection: true)
        
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        
        let filterVC = FilterViewController(options: [filterTypes, dateRange])
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
        
        let selectActionTypes = filterTypes != Set(Action.ActionType.allCases)
        let requiresFiltering: Bool = selectActionTypes || filterDateRange != nil
        
        if requiresFiltering {
            actions = actions.filter { action in
                if selectActionTypes {
                    guard let type = action.type, self.filterTypes.contains(type) else {
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
        
        let bundle = Bundle(for: EntityAlertsViewController.self)
        let filterName = requiresFiltering ? "iconFormFilterFilled" : "iconFormFilter"
        filterBarButtonItem.image = UIImage(named: filterName, in: bundle, compatibleWith: nil)
        
        self.actions = actions
    }
    
}
