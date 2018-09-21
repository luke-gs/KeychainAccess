//
//  SelectStoppedEntityViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import PromiseKit

/// View model for a single select stopped entity item
open class SelectStoppedEntityItemViewModel: Equatable {
    
    public let entity: MPOLKitEntity
    public let category: String?
    public let title: String?
    public let subtitle: String?
    public let image: ImageLoadable?
    public let borderColor: UIColor?
    public let imageColor: UIColor?

    public init(entity: MPOLKitEntity, summary: EntitySummaryDisplayable) {
        self.entity = entity
        self.category = summary.category
        self.title = summary.title
        self.subtitle = summary.detail1
        self.borderColor = summary.borderColor
        self.imageColor = summary.iconColor
        self.image = summary.thumbnail(ofSize: .small)
    }

    public static func ==(lhs: SelectStoppedEntityItemViewModel, rhs: SelectStoppedEntityItemViewModel) -> Bool {
        return lhs.entity == rhs.entity
    }
}

/// View model for adding a stopped entity.
open class SelectStoppedEntityViewModel: CADFormCollectionViewModel<SelectStoppedEntityItemViewModel> {
    
    // MARK: - Properties
    
    /// Delegate action to interested party
    open var onSelectEntity: ((SelectStoppedEntityItemViewModel) -> Void)?

    /// array of strings that match the serverTypeRepresentations of entities
    open var allowedEntities: [MPOLKitEntity.Type]? {
        didSet {
            updateSections()
        }
    }

    // MARK: - Lifecycle
    
    public override init() {
        super.init()
        updateSections()

        // Refresh list whenever recently viewed entities change
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecentlyViewedChanged), name: EntityBucket.didUpdateNotificationName, object: nil)
    }

    @objc open func handleRecentlyViewedChanged() {
        // Update sections when recently viewed entities changes
        updateSections()
    }

    open func updateSections() {
        var recentlyViewed = UserSession.current.recentlyViewed.entities

        if let allowedEntities = allowedEntities {
            recentlyViewed = recentlyViewed.filter({entity in
                allowedEntities.contains(where: { $0 == type(of: entity) })
            })
        }

        let summaryDisplayFormatter: EntitySummaryDisplayFormatter = .default

        let viewModels: [SelectStoppedEntityItemViewModel] = recentlyViewed.reversed().compactMap { entity in
            guard let summary = summaryDisplayFormatter.summaryDisplayForEntity(entity) else { return nil }
            return SelectStoppedEntityItemViewModel(entity: entity, summary: summary)
        }
        self.sections = [CADFormCollectionSectionViewModel(title: "Recently Viewed", items: viewModels)]
    }
    
    /// Gets called from view controller when index path is selected
    open func didSelectItem(at indexPath: IndexPath) {
        let entity = item(at: indexPath)!
        self.onSelectEntity?(entity)
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return SelectStoppedEntityViewController(viewModel: self)
    }
    
    // MARK: - Overridable
    
    /// The text for the search button
    open func searchButtonText() -> String {
        return "Search for Another Entity"
    }
    
    // MARK: - Override
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Add Another Entity", comment: "Add Another Entity title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Entities To Select", comment: "")
    }
    
    /// Content subtitle shown when no results
    override open func noContentSubtitle() -> String? {
        return nil
    }
    
    /// Expandable sections
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }
}
