//
//  PersonOccurrencesViewController.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Foundation
import MPOLKit

// TEMP stuff
open class PersonOccurrencesViewController: EntityOccurrencesViewController, FilterViewControllerDelegate {
    
    
    // MARK: - Public properties
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    
    // MARK: - Private properties
    
    private let filterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
    
    private var person: Person? {
        didSet {
            let eventCount = person?.events?.count ?? 0
            sidebarItem.count = UInt(eventCount)
            
            updateNoContentSubtitle()
            reloadSections()
        }
    }
    
    private var events: [Event] = [] {
        didSet {
            loadingManager.state = events.isEmpty ? .noContent: .loaded
            collectionView?.reloadData()
        }
    }
    
    private var filterTypes: Set<String>?
    
    private var filterDateRange: FilterDateRange?
    
    private var dateSorting: DateSorting = .newest
    
    
    /*
    private var bailOrders: [BailOrder]?
    private var cautions: [Caution]?
    private var fieldContacts: [FieldContact]?
    private var interventionOrders: [InterventionOrder]?
    private var warrants: [Warrant]?
    private var whereabouts: [Whereabouts]?
    private var missingPersons: [MissingPerson]?
    private var familyIncidents: [FamilyIncident]?
    */
    
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
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormDetailCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return events.isEmpty ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.accessoryView = cell.accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)
        
        let event = events[indexPath.item]
        let cellTexts = appropriateTexts(for: event)
        
        cell.titleLabel.text = cellTexts.titleText
        cell.subtitleLabel.text = cellTexts.subtitleText
        cell.detailLabel.text = cellTexts.detailText
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let detailViewController: UIViewController?
        
        switch events[indexPath.item] {
        case let fieldContact as FieldContact:
            let fieldContactVC = FieldContactDetailViewController()
            fieldContactVC.event = fieldContact
            detailViewController = fieldContactVC
        case let bailOrder as BailOrder:
            let bailOrderVC = BailOrderDetailViewController()
            bailOrderVC.event = bailOrder
            detailViewController = bailOrderVC
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
            
            // TODO: Refactor for StringsDict pluralization
            let eventCount = events.count
            if eventCount > 0 {
                let baseString = eventCount > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
                header.text = String(format: baseString, eventCount)
            } else {
                header.text = nil
            }
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
        reloadSections()
    }
    
    
    // MARK: - Private methods
    
    @objc private func filterItemDidSelect(_ item: UIBarButtonItem) {
        var allTypes = Set<String>()
        person?.events?.forEach {
            if let type = $0.eventType {
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
        
        let filterList = FilterList(title: NSLocalizedString("Involvement Types", comment: ""), displayStyle: .detailList, options: allSortedTypes, selectedIndexes: selectedIndexes, allowsNoSelection: true, allowsMultipleSelection: true)
        
        let dateRange = filterDateRange ?? FilterDateRange(title: NSLocalizedString("Date Range", comment: ""), startDate: nil, endDate: nil, requiresStartDate: false, requiresEndDate: false)
        let sorting = FilterList(title: "Sort By", displayStyle: .list, options: DateSorting.allCases, selectedIndexes: [DateSorting.allCases.index(of: dateSorting) ?? 0])
        
        
        let filterVC = FilterViewController(options: [filterList, dateRange, sorting])
        filterVC.title = NSLocalizedString("Filter Involvements", comment: "")
        filterVC.delegate = self
        let navController = PopoverNavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .popover
        if let popoverPresentationController = navController.popoverPresentationController {
            popoverPresentationController.barButtonItem = item
        }
        
        present(navController, animated: true)
    }
    
    private func updateNoContentSubtitle() {
        let label = loadingManager.noContentView.subtitleLabel
        
        if person?.actions?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = entity {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            label.text = String(format: NSLocalizedString("This %@ has no involvements", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            label.text = NSLocalizedString("This filter has no matching involvements", comment: "")
        }
    }
    
    private func reloadSections() {
        var events = person?.events ?? []
        
        let requiresFiltering = filterTypes != nil || filterDateRange != nil
        if requiresFiltering {
            events = events.filter { event in
                if let filterTypes = self.filterTypes {
                    guard let type = event.eventType, filterTypes.contains(type) else {
                        return false
                    }
                }
                if let dateFilter = self.filterDateRange {
                    guard let date = event.date, dateFilter.contains(date) else {
                        return false
                    }
                }
                return true
            }
        }
        
        let dateSorting = self.dateSorting.compare(_:_:)
        events.sort { dateSorting(($0.date ?? .distantPast), ($1.date ?? .distantPast)) }
        self.events = events
        
        filterBarButtonItem.isActive = requiresFiltering
    }
    
    // Seems like a common pattern, potential refactor point to have a standard formatter for these?
    private func appropriateTexts(for event: Event) -> (titleText: String?, subtitleText: String?, detailText: String?) {
        let titleText = event.eventType
        let subtitleText = formattedTitle(for: event.date)
        let detailText = event.eventDescription
        
        return (titleText: titleText, subtitleText: subtitleText, detailText: detailText)
    }
    
    private func formattedTitle(for date: Date?) -> String {
        let text: String
        if let date = date {
            text = DateFormatter.mediumNumericDate.string(from: date)
        } else {
            text = "unknown"
        }
        return "Occurred on \(text)"
    }
}
