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
    private enum Sorting: Pickable {
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
        
        var title: String? {
            switch self {
            case .dateNewest: return NSLocalizedString("Newest", comment: "")
            case .dateOldest: return NSLocalizedString("Oldest", comment: "")
            case .title:      return NSLocalizedString("Title", comment: "")
            }
        }
        
        var subtitle: String? {
            return nil
        }
        
        static let allCases: [Sorting] = [.dateNewest, .dateOldest, .title]
    }
    
    
    // MARK: - Public Properties
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    
    // MARK: - Private properties
    
    private let filterBarButtonItem: UIBarButtonItem
    
    private var filterDateRange: FilterDateRange?
    
    private var person: Person? {
        didSet {
            sidebarItem.count = UInt(person?.criminalHistory?.count ?? 0)
            updateNoContentSubtitle()
            reloadSections()
        }
    }
    
    private var criminalHistory: [CriminalHistory] = [] {
        didSet {
            hasContent = criminalHistory.isEmpty == false
            collectionView?.reloadData()
        }
    }
    
    private var sorting: Sorting = .dateNewest
    
    
    // MARK: - Initializers
    
    public override init() {
        filterBarButtonItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: nil, action: nil)
        
        super.init()
        
        hasContent = false
        
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
        
        noContentTitleLabel?.text = NSLocalizedString("No Criminal History Found", bundle: .mpolKit, comment: "")
        updateNoContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return criminalHistory.isEmpty ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return criminalHistory.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        let history = criminalHistory[indexPath.item]
        let text = cellText(for: history)
        
        cell.titleLabel.text = text.title
        cell.subtitleLabel.text = text.subtitle
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            
            let orderCount = criminalHistory.count
            if orderCount > 0 {
                let baseString = orderCount > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
                header.text = String(format: baseString, orderCount)
            } else {
                header.text = nil
            }
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
        let history = criminalHistory[indexPath.item]
        let text = cellText(for: history)
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: text.title, subtitle: text.subtitle, inWidth: itemWidth, compatibleWith: traitCollection)
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
    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        if person?.criminalHistory?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = entity {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            label.text = String(format: NSLocalizedString("This %@ has no criminal history", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            label.text = NSLocalizedString("This filter has no matching history", comment: "")
        }
    }
    
    private func reloadSections() {
        var criminalHistory = person?.criminalHistory ?? []
        if let dateRange = filterDateRange {
            criminalHistory = criminalHistory.filter { history in
                if let date = history.lastOccurred, dateRange.contains(date) {
                    return true
                }
                return false
            }
        }
        criminalHistory.sort(by: sorting.compare(_:_:))
        self.criminalHistory = criminalHistory
        
        let filterKey: AssetManager.ImageKey = sorting != .dateNewest || filterDateRange != nil ? .filterFilled : .filter
        filterBarButtonItem.image = AssetManager.shared.image(forKey: filterKey)
    }
    
    private func cellText(for history: CriminalHistory) -> (title: String, subtitle: String) {
        var offenceCountText = ""
        if let offenceCount = history.offenceCount {
            offenceCountText = "(\(offenceCount)) "
        }
        
        let lastOccurredDateString: String
        if let lastOccurred = history.lastOccurred {
            lastOccurredDateString = DateFormatter.mediumNumericDate.string(from: lastOccurred)
        } else {
            lastOccurredDateString = NSLocalizedString("Unknown", bundle: .mpolKit, comment: "Unknown date")
        }
        
        let title = offenceCountText + (history.offenceDescription?.ifNotEmpty() ?? NSLocalizedString("Unknown Offence", bundle: .mpolKit, comment: ""))
        let subtitle = String(format: NSLocalizedString("Last occurred: %@", bundle: .mpolKit, comment: ""), lastOccurredDateString)
        
        return (title, subtitle)
    }
    
}
