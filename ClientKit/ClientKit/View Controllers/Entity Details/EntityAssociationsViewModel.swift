//
//  EntityAssociationsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

open class EntityAssociationViewModel: EntityDetailFilterableFormViewModel {
    
    /// Associated persons
    private var persons: [Person] {
        return entity?.associatedPersons ?? []
    }
    
    /// Associated vehicles
    private var vehicles: [Vehicle] {
        return entity?.associatedVehicles ?? []
    }

    /// Associated locations
    private var locations: [Address] {
        return entity?.addresses ?? []
    }
    
    /// Total associations count
    private var count: Int {
        return persons.count + vehicles.count + locations.count
    }

    private weak var searchDelegate: SearchDelegate?

    private let summaryDisplayFormatter: EntitySummaryDisplayFormatter
    
    // MARK: - Lifecycle
    
    public init(delegate: SearchDelegate?, summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default) {
        self.searchDelegate = delegate
        self.summaryDisplayFormatter = summaryDisplayFormatter
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        
        if !persons.isEmpty {
            let count = persons.count
            builder += HeaderFormItem(text: String.localizedStringWithFormat(NSLocalizedString("%d PEOPLE", comment: ""), count), style: .collapsible)
            
            for person in persons {
                let displayable = PersonSummaryDisplayable(person)
                builder += displayable.summaryFormItem(isCompact: isCompact || !wantsThumbnails)
                    .onSelection({ [weak self] _ in
                        if let presentable = self?.summaryDisplayFormatter.presentableForEntity(person) {
                            self?.searchDelegate?.handlePresentable(presentable)
                        }
                    })
            }
        }
        
        if !vehicles.isEmpty {
            let count = vehicles.count
            builder += HeaderFormItem(text: String.localizedStringWithFormat(NSLocalizedString("%d VEHICLE(S)", comment: ""), count), style: .collapsible)
            
            for vehicle in vehicles {
                let displayable = VehicleSummaryDisplayable(vehicle)
                builder += displayable.summaryFormItem(isCompact: isCompact || !wantsThumbnails)
                    .onSelection({ [weak self] _ in
                        if let presentable = self?.summaryDisplayFormatter.presentableForEntity(vehicle) {
                            self?.searchDelegate?.handlePresentable(presentable)
                        }
                    })
            }
        }

        if !locations.isEmpty {
            let count = locations.count
            builder += HeaderFormItem(text: String.localizedStringWithFormat(NSLocalizedString("%d LOCATION(S)", comment: ""), count), style: .collapsible)

            for location in locations {
                let displayable = AddressSummaryDisplayable(location)
                builder += displayable.summaryFormItem(isCompact: isCompact || !wantsThumbnails)
                    .onSelection({ [weak self] _ in
                        if let presentable = self?.summaryDisplayFormatter.presentableForEntity(location) {
                            self?.searchDelegate?.handlePresentable(presentable)
                        }
                    })
            }
        }
        
        delegate?.updateLoadingState(count == 0 ? .noContent : .loaded)
    }
    
    open override var title: String? {
        return NSLocalizedString("Associations", bundle: .mpolKit, comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Associations Found", comment: "")
    }
    
    open override var noContentSubtitle: String? {
        let name: String
        if let entity = entity {
            name = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            name = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        return String(format: NSLocalizedString("This %@ has no associations", bundle: .mpolKit, comment: ""), name)
    }
    
    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .alert)
    }
    
    open override var sidebarCount: UInt? {
        return UInt(count)
    }
    
    open override var rightBarButtonItems: [UIBarButtonItem]? {
        filterButton.isEnabled = false
        
        var buttons: [UIBarButtonItem] = [filterButton]
        if !isCompact {
            let image = AssetManager.shared.image(forKey: wantsThumbnails ? .list : .thumbnail)
            buttons.append(UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleThumbnails)))
        }
        return buttons
    }
    
    open override func traitCollectionDidChange(_ traitCollection: UITraitCollection, previousTraitCollection: UITraitCollection?) {
        self.traitCollection = traitCollection
    }
    
    // MARK: - Filtering (currently disabled)
    
    open override var isFilterApplied: Bool {
        return false
    }
    
    open override var filterOptions: [FilterOption] {
        return []
    }
    
    open override func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        
    }
    
    // MARK: - Thumbnails / List
    
    private var traitCollection: UITraitCollection? {
        didSet {
            delegate?.reloadData()
            delegate?.updateBarButtonItems()
        }
    }
    
    private var isCompact: Bool {
        return traitCollection?.horizontalSizeClass == .compact
    }
    
    private var wantsThumbnails: Bool = true {
        didSet {
            if wantsThumbnails == oldValue {
                return
            }
            
            if !isCompact {
                delegate?.updateBarButtonItems()
                delegate?.reloadData()
            }
        }
    }
    
    @objc private func toggleThumbnails() {
        wantsThumbnails = !wantsThumbnails
    }
}
