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
    
    /// Total associations count
    private var count: Int {
        return persons.count + vehicles.count
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        builder.title = title
        
        if !persons.isEmpty {
            builder += HeaderFormItem(text: String(format: (count == 1 ? "%d PERSON" : "%d PEOPLE"), persons.count), style: .collapsible)
            
            for person in persons {
                builder += formItem(for: person, in: viewController)
            }
        }
        
        if !vehicles.isEmpty {
            builder += HeaderFormItem(text: String(format: (count == 1 ? "%d VEHICLE" : "%d VEHICLES"), vehicles.count), style: .collapsible)
            
            for vehicle in vehicles {
                builder += formItem(for: vehicle, in: viewController)
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
    
    open override var filterApplied: Bool {
        return false
    }
    
    open override var filterOptions: [FilterOption] {
        return []
    }
    
    open override func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        
    }
    
    // MARK: - Internal
    
    private func formItem(for entity: Entity, in viewController: UIViewController) -> BaseFormItem {
        
        // Create displayable
        let displayable: EntitySummaryDisplayable
        switch entity {
        case is Person:     displayable = PersonSummaryDisplayable(entity)
        case is Vehicle:    displayable = VehicleSummaryDisplayable(entity)
        default:            fatalError()
        }
        
        // Create form item
        if isCompact || !wantsThumbnails {
            return SummaryListFormItem()
                .category(displayable.category)
                .title(displayable.title)
                .subtitle([displayable.detail1, displayable.detail2].joined(separator: ThemeConstants.dividerSeparator).ifNotEmpty())
                .badge(displayable.badge)
                .badgeColor(displayable.borderColor)
                .borderColor(displayable.borderColor)
                .image(displayable.thumbnail(ofSize: .small))
                .imageTintColor(displayable.iconColor)
                .highlightStyle(.fade)
                .accessory(ItemAccessory(style: .disclosure))
                .onSelection({ [unowned self] _ in
                    self.entityDetailsDelegate?.controller(viewController, didSelectEntity: entity)
                })
        } else {
            return SummaryThumbnailFormItem()
                .style(.hero)
                .category(displayable.category)
                .title(displayable.title)
                .subtitle(displayable.detail1 ?? displayable.detail2)
                .detail(displayable.detail1?.isEmpty ?? true ? nil : displayable.detail2)
                .badge(displayable.badge)
                .badgeColor(displayable.borderColor)
                .borderColor(displayable.borderColor)
                .image(displayable.thumbnail(ofSize: .large))
                .imageTintColor(displayable.iconColor)
                .highlightStyle(.fade)
                .onSelection({ [unowned self] _ in
                    self.entityDetailsDelegate?.controller(viewController, didSelectEntity: entity)
                })
        }
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
            if wantsThumbnails == oldValue { return }
            
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
