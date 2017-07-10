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
    
    private let filterBarButtonItem: UIBarButtonItem
    
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
            hasContent = events.isEmpty == false
            collectionView?.reloadData()
        }
    }
    
    private var filterTypes: Set<String>?
    
    
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
        let bundle = Bundle(for: EntityAlertsViewController.self)
        filterBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: bundle, compatibleWith: nil), style: .plain, target: nil, action: nil)
        
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
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
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
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
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
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
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
        return CollectionViewFormExpandingHeaderView.minimumHeight
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
                if selectedIndexes.isEmpty == false {
                    self.filterTypes = Set(filterList.options[selectedIndexes] as! [String])
                } else {
                    self.filterTypes = nil
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
        
        let filterVC = FilterViewController(options: [filterList])
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
        guard let label = noContentSubtitleLabel else { return }
        
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
        
        let requiresFiltering = filterTypes != nil
        
        if let filterTypes = self.filterTypes {
            events = events.filter { event in
                guard let type = event.eventType, filterTypes.contains(type) else {
                    return false
                }
                return true
            }
        }
        
        let bundle = Bundle(for: PersonOccurrencesViewController.self)
        let filterName = requiresFiltering ? "iconFormFilterFilled" : "iconFormFilter"
        filterBarButtonItem.image = UIImage(named: filterName, in: bundle, compatibleWith: nil)
        
        events.sort { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
        
        self.events = events
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
