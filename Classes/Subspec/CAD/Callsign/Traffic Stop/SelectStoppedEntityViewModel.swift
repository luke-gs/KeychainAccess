//
//  SelectStoppedEntityViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import PromiseKit

/// View model for a single select stopped entity item
open class SelectStoppedEntityItemViewModel: Equatable {
    
    public let id: String // TODO: Swap out with MPOLKITEntity or Entity for comparing
    public let category: String
    public let title: String
    public let subtitle: String?
    public let image: UIImage
    public let borderColor: UIColor?
    public let imageColor: UIColor?
    
    public init(id: String, category: String, title: String, subtitle: String? = nil, image: UIImage, borderColor: UIColor? = nil, imageColor: UIColor? = nil) {
        self.id = id
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.borderColor = borderColor
        self.imageColor = imageColor
    }
    
    public static func ==(lhs: SelectStoppedEntityItemViewModel, rhs: SelectStoppedEntityItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

/// View model for adding a stopped entity.
open class SelectStoppedEntityViewModel: CADFormCollectionViewModel<SelectStoppedEntityItemViewModel> {
    
    // MARK: - Properties
    
    /// Delegate action to interested party
    open var onSelectEntity: ((SelectStoppedEntityItemViewModel) -> Void)?
    
    // MARK: - Lifecycle
    
    public override init() {
        super.init()
        
        self.sections = [
            CADFormCollectionSectionViewModel(title: "RECENTLY VIEWED", items: [
                SelectStoppedEntityItemViewModel(id: "1", category: "DS1", title: "NLJ400", subtitle: "2009 Bentley Continental GTC  •  Sedan  •  Red/Black", image: AssetManager.shared.image(forKey: .entityCarSmall)!),
                SelectStoppedEntityItemViewModel(id: "2", category: "DS1", title: "JAN258", subtitle: "2015 Toyota Avalon  •  Sedan  •  White/White", image: AssetManager.shared.image(forKey: .entityCarSmall)!),
                SelectStoppedEntityItemViewModel(id: "3", category: "DS1", title: "KSO196", subtitle: "2010 Ford Escape  •  SUV  •  Green/Black", image: AssetManager.shared.image(forKey: .entityCarSmall)!)
            ])
        ]
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
