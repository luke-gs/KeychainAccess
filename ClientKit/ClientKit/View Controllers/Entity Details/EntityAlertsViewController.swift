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
            let sidebarItem = self.sidebarItem
            sidebarItem.count = UInt(entity?.alerts?.count ?? 0)
            sidebarItem.alertColor = entity?.alertLevel?.color
            
            updateNoContentSubtitle()
            reloadSections()
        }
    }
    
    
    // MARK: - Private properties
    
    private let filterBarButtonItem: UIBarButtonItem
    
    private var filteredAlertLevels: Set<Alert.Level> = Set(Alert.Level.allCases)
    
    private var filterDateRange: FilterDateRange?
    
    private var dateSorting: DateSorting = .newest
    
    private var sections: [[Alert]] = [[]] {
        didSet {
            if oldValue.isEmpty == true && sections.isEmpty == true {
                return
            }
            
            hasContent = sections.isEmpty == false
            collectionView?.reloadData()
        }
    }
    
    private var statusDotCache: [Alert.Level: UIImage] = [:]
    
    private var collapsedSections: [String: Set<Alert.Level>] = [:]
    
    
    
    // MARK: - Initializers
    
    public override init() {
        filterBarButtonItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .filter), style: .plain, target: nil, action: nil)
        
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
        
        noContentTitleLabel?.text = NSLocalizedString("No Alerts Found", bundle: .mpolKit, comment: "")
        updateNoContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let alerts = sections[section]
        let level = alerts.first!.level!
        if collapsedSections[entity!.id]?.contains(level) ?? false {
            // Don't assume there is a collapsed sections here because we should load it lazily.
            return 0
        } else {
            return alerts.count
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        cell.highlightStyle     = .fade
        cell.selectionStyle     = .fade
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()

        let alert = sections[indexPath.section][indexPath.item]
        
        if let alertLevel = alert.level {
            if let cachedImage = statusDotCache[alertLevel] {
                cell.imageView.image = cachedImage
            } else {
                let image = UIImage.statusDot(withColor: alertLevel.color!)
                statusDotCache[alertLevel] = image
                cell.imageView.image = image
            }
        } else  {
            cell.imageView.image = nil
        }
        
        cell.titleLabel.text  = alert.title
        cell.detailLabel.text = alert.details
        
        if let date = alert.effectiveDate {
            cell.subtitleLabel.text = NSLocalizedString("Effective from ", bundle: .mpolKit, comment: "") + DateFormatter.shortDate.string(from: date)
        } else {
            cell.subtitleLabel.text = NSLocalizedString("Effective date unknown", bundle: .mpolKit, comment: "")
        }
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            
            let alerts = sections[indexPath.section]
            let alertCount = alerts.count
            let personId = self.entity!.id
            let level = alerts.first!.level!
            
            if alertCount > 0, let levelDescription = level.localizedDescription(plural: alertCount > 1) {
                header.text = "\(alertCount) \(levelDescription.localizedUppercase) "
                header.showsExpandArrow = true
                
                header.tapHandler = { [weak self] (headerView, indexPath) in
                    guard let `self` = self else { return }
                    
                    var collapsedSections = self.collapsedSections[personId] ?? []
                    if collapsedSections.remove(level) == nil {
                        // This section wasn't in there and didn't remove
                        collapsedSections.insert(level)
                    }
                    self.collapsedSections[personId] = collapsedSections
                    
                    self.collectionView?.reloadData()
                }
                
                header.isExpanded = !(collapsedSections[personId]?.contains(level) ?? false)
            } else {
                header.text = nil
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
    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        if entity?.alerts?.isEmpty ?? true {
            let entityDisplayName: String
            if let entity = entity {
                entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
            } else {
                entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
            }
            
            label.text = String(format: NSLocalizedString("This %@ has no alerts", bundle: .mpolKit, comment: ""), entityDisplayName)
        } else {
            label.text = NSLocalizedString("This filter has no matching alerts", comment: "")
        }
        
    }
    
    private func reloadSections() {
        
        var alerts = entity?.alerts ?? []
        
        let dateSorting = self.dateSorting.compare(_:_:)
        
        func sortingRule(_ alert1: Alert, alert2: Alert) -> Bool {
            let alert1Level = alert1.level?.rawValue ?? 0
            let alert2Level = alert2.level?.rawValue ?? 0
            
            if alert1Level > alert2Level { return true }
            if alert2Level > alert1Level { return false }
            
            return dateSorting((alert1.effectiveDate ?? Date.distantPast), (alert2.effectiveDate ?? Date.distantPast))
        }
        
        let selectAlertLevels = filteredAlertLevels != Set(Alert.Level.allCases)
        let requiresFiltering: Bool = selectAlertLevels || filterDateRange != nil
        
        if requiresFiltering {
            alerts = alerts.filter( { alert in
                if selectAlertLevels {
                    guard let alertLevel = alert.level, self.filteredAlertLevels.contains(alertLevel) else {
                        return false
                    }
                }
                if let filteredDateRange = self.filterDateRange {
                    guard let date = alert.effectiveDate, filteredDateRange.contains(date) else {
                        return false
                    }
                }
                return true
            }).sorted(by: sortingRule)
        } else {
            alerts.sort(by: sortingRule)
        }
        
        if alerts.isEmpty {
            self.sections = []
            return
        }
        
        var sections: [[Alert]] = []
        
        while let firstAlertLevel = alerts.first?.level {
            if let firstDifferentIndex = alerts.index(where: { $0.level != firstAlertLevel }) {
                let alertLevelSlice = alerts.prefix(upTo: firstDifferentIndex)
                alerts.removeFirst(firstDifferentIndex)
                sections.append(Array(alertLevelSlice))
            } else {
                sections.append(alerts)
                alerts.removeAll()
            }
        }
        
        self.sections = sections
        
        let filterKey: AssetManager.ImageKey = requiresFiltering ? .filterFilled : .filter
        filterBarButtonItem.image = AssetManager.shared.image(forKey: filterKey)
    }
    
}

