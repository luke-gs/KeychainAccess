//
//  TaskDetailsOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 15/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class TaskDetailsOverviewViewModel: TaskDetailsViewModel {

    /// The identifier for this task
    open let identifier: String

    /// The location of this task, if applicable
    open var location: CADLocationType?
    
    open weak var delegate: CADFormCollectionViewModelDelegate?
    
    /// Lazy var for creating view model content
    open var sections: [CADFormCollectionSectionViewModel<TaskDetailsOverviewItemViewModel>] = [] {
        didSet {
            delegate?.sectionsUpdated()
        }
    }
    
    public init(identifier: String) {
        self.identifier = identifier
        loadData()
    }
    
    open func createViewController() -> TaskDetailsViewController {
        return TaskDetailsOverviewViewController(viewModel: self)
    }
    
    open func reloadFromModel() {
        loadData()
    }
    
    open func createFormViewController() -> FormBuilderViewController {
        return TaskDetailsOverviewFormViewController(viewModel: self)
    }
    
    
    open lazy var mapViewModel: TasksMapViewModel? = {
        return TasksMapViewModel()
    }()

    open func loadData() {
        MPLRequiresConcreteImplementation()
    }
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
    
    /// The image to use in the sidebar
    open func sidebarImage() -> UIImage? {
        return AssetManager.shared.image(forKey: .info)
    }
    
    /// Present "Directions, Street View, Search" options on address
    open func presentAddressPopover(from cell: CollectionViewFormCell) {
        if let location = location, let coordinate = location.coordinate {
            delegate?.present(TaskItemScreen.addressLookup(source: cell, coordinate: coordinate, address: location.displayText))
        }
    }

}
