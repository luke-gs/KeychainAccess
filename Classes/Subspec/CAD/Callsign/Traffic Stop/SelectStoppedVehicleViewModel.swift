//
//  SelectStoppedVehicleViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import PromiseKit

/// View model for a single select stopped vehicle item
open class SelectStoppedVehicleItemViewModel {
    public let category: String
    public let title: String
    public let subtitle: String?
    public let image: UIImage
    public let borderColor: UIColor?
    public let imageColor: UIColor?
    
    public init(category: String, title: String, subtitle: String? = nil, image: UIImage, borderColor: UIColor? = nil, imageColor: UIColor? = nil) {
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.borderColor = borderColor
        self.imageColor = imageColor
    }
}

/// View model for selecting a stopped vehicle
open class SelectStoppedVehicleViewModel: CADFormCollectionViewModel<SelectStoppedVehicleItemViewModel> {
    
    // MARK: - Class Methods
    
    /// Presents the view controller and returns the appropriate promise
    open static func prompt(using delegate: CADFormCollectionViewModelDelegate?) -> Promise<Void> {
        let viewModel = SelectStoppedVehicleViewModel()
        delegate?.presentPushedViewController(viewModel.createViewController(), animated: true)
        return viewModel.promiseTuple.promise
    }
    
    // MARK: - Properties
    
    /// The promise that completes on user interaction.
    // TODO: Return Promise<Vehicle> when it becomes available to the kit
    open let promiseTuple: Promise<Void>.PendingTuple = Promise<Void>.pending()
    
    // MARK: - Lifecycle
    
    public override init() {
        super.init()
        
        self.sections = [
            CADFormCollectionSectionViewModel(title: "FROM MY ACTION LIST", items: [
                SelectStoppedVehicleItemViewModel(category: "DS1", title: "ARP067", subtitle: "2017 Model S P100D  •  Coupe  •  Black/Black", image: AssetManager.shared.image(forKey: .entityCarSmall)!, borderColor: .red, imageColor: .red)
            ]),
            CADFormCollectionSectionViewModel(title: "RECENTLY VIEWED", items: [
                SelectStoppedVehicleItemViewModel(category: "DS1", title: "NLJ400", subtitle: "2009 Bentley Continental GTC  •  Sedan  •  Red/Black", image: AssetManager.shared.image(forKey: .entityCarSmall)!),
                SelectStoppedVehicleItemViewModel(category: "DS1", title: "JAN258", subtitle: "2015 Toyota Avalon  •  Sedan  •  White/White", image: AssetManager.shared.image(forKey: .entityCarSmall)!),
                SelectStoppedVehicleItemViewModel(category: "DS1", title: "KSO196", subtitle: "2010 Ford Escape  •  SUV  •  Green/Black", image: AssetManager.shared.image(forKey: .entityCarSmall)!)
            ])
        ]
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return SelectStoppedVehicleViewController(viewModel: self)
    }
    
    // MARK: - Overridable
    
    /// The text for the search button
    open func searchButtonText() -> String {
        return "Search for Another Vehicle"
    }
    
    // MARK: - Override
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Select Stopped Vehicle", comment: "Select Stopped Vehicle title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Vehicles To Select", comment: "")
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
