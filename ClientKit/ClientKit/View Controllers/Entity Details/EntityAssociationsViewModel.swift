//
//  EntityAssociationsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 14/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PublicSafetyKit

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

    // return color of assossication with highest alert level
    private var highestAssociationAlertColor: UIColor? {

        let associations: [Entity] = persons.compactMap { $0 as Entity } +
            vehicles.compactMap { $0 as Entity } +
            locations.compactMap { $0 as Entity }

        var highestAlertLevel: Alert.Level?

        for association in associations {
            // if highestAlertLevel is set, compare it to current association alertLevel
            if var highestAlertLevel = highestAlertLevel {
                if let associationAlertLevel = association.alertLevel, associationAlertLevel > highestAlertLevel {
                    highestAlertLevel = associationAlertLevel

                    // if highestAlertLevel is at highest posible outcome return
                    if highestAlertLevel == .high {
                        return highestAlertLevel.color
                    }
                }
            // if highestAlertLevel not set it to current associations alert
            } else {
                highestAlertLevel = association.alertLevel
            }
        }

        return highestAlertLevel?.color
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
            builder += LargeTextHeaderFormItem(text: String.localizedStringWithFormat(NSLocalizedString("%d People", comment: ""), count), separatorColor: .clear)
            
            for person in persons {
                let displayable = PersonSummaryDisplayable(person)
                builder += displayable.associatedSummaryFormItem(style: style(for: person))
                    .onSelection { [weak self] _ in
                        if let presentable = self?.summaryDisplayFormatter.presentableForEntity(person) {
                            self?.searchDelegate?.handlePresentable(presentable)
                        }
                }
            }
        }
        
        if !vehicles.isEmpty {
            let count = vehicles.count
            builder += LargeTextHeaderFormItem(text: String.localizedStringWithFormat(NSLocalizedString("%d Vehicle(s)", comment: ""), count), separatorColor: .clear)
            
            for vehicle in vehicles {
                let displayable = VehicleSummaryDisplayable(vehicle)
                builder += displayable.associatedSummaryFormItem(style: style(for: vehicle))
                    .onSelection { [weak self] _ in
                        if let presentable = self?.summaryDisplayFormatter.presentableForEntity(vehicle) {
                            self?.searchDelegate?.handlePresentable(presentable)
                        }
                }
            }
        }

        if !locations.isEmpty {
            let count = locations.count
            builder += LargeTextHeaderFormItem(text: String.localizedStringWithFormat(NSLocalizedString("%d Location(s)", comment: ""), count), separatorColor: .clear)

            for location in locations {
                let displayable = AddressSummaryDisplayable(location)
                builder += displayable.associatedSummaryFormItem(style: style(for: location))
                    .onSelection { [weak self] _ in
                        if let presentable = self?.summaryDisplayFormatter.presentableForEntity(location) {
                            self?.searchDelegate?.handlePresentable(presentable)
                        }
                }
            }
        }
        
        delegate?.updateLoadingState(count == 0 ? .noContent : .loaded)
    }
    
    open override var title: String? {
        return NSLocalizedString("Associations", comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Associations Found", comment: "")
    }
    
    open override var noContentSubtitle: String? {
        let name: String
        if let entity = entity {
            name = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            name = NSLocalizedString("entity", comment: "")
        }
        return String(format: NSLocalizedString("This %@ has no associations", comment: ""), name)
    }
    
    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .association)
    }
    
    open override var sidebarCount: UInt? {
        return UInt(count)
    }

    internal override func didSetEntity() {
        super.didSetEntity()
        updateSidebarAlertColor()
    }

    private func updateSidebarAlertColor() {

        if let color = highestAssociationAlertColor {
            delegate?.updateSidebarAlertColor(color)
        }
    }
    
    open override var rightBarButtonItems: [UIBarButtonItem]? {
        filterButton.isEnabled = false
        
        var buttons: [UIBarButtonItem] = [filterButton]
        if !isCompact {
            let image = AssetManager.shared.image(forKey: style == .grid ? .navBarThumbnailSelected : .navBarThumbnail)
            buttons.append(UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(updateStyle)))
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
    
    // MARK: - Entity Display Style

    public private(set) var style: EntityDisplayStyle = .grid {
        didSet {
            if style == oldValue {
                return
            }

            if !isCompact {
                delegate?.updateBarButtonItems()
                delegate?.reloadData()
            }
        }
    }
    
    private var traitCollection: UITraitCollection? {
        didSet {
            delegate?.reloadData()
            delegate?.updateBarButtonItems()
        }
    }
    
    private var isCompact: Bool {
        return traitCollection?.horizontalSizeClass == .compact
    }
    
    @objc private func updateStyle() {
        style = style == .grid ? . list : .grid
    }

    private func style(for entity: Entity) -> EntityDisplayStyle {
        switch entity {
            case is Vehicle, is Address:
                return .list
            default:
                return isCompact ? .list : style
        }
    }
}
