//
//  IncidentOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentOverviewViewModel: TaskDetailsViewModel {
    
    public func createViewController() -> UIViewController {
        return IncidentOverviewViewController(viewModel: self)
    }
    
    open func createFormViewController() -> FormBuilderViewController {
        return IncidentOverviewFormViewController(viewModel: self)
    }
    
    
    /// Lazy var for creating view model content
    public var sections: [CADFormCollectionSectionViewModel<IncidentOverviewItemViewModel>] = {
        return [
            CADFormCollectionSectionViewModel(title: "Overview",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Incident Location",
                                                                              value: "188 Smith Street, Fitzroy VIC 3065",
                                                                              image: AssetManager.shared.image(forKey: .location),
                                                                              width: .column(1)),
                                                
                                                IncidentOverviewItemViewModel(title: "Priority",
                                                                              value: "P1",
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Primary Code",
                                                                              value: "AS4205",
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Secondary Code",
                                                                              value: "MP0001529",
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Patrol Area",
                                                                              value: "Collingwood",
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Created",
                                                                              value: "Today, 10:12",
                                                                              width: .column(4)),
                                                
                                                IncidentOverviewItemViewModel(title: "Last Updated",
                                                                              value: "2 mins ago",
                                                                              width: .column(4)),
            ]),
            
            CADFormCollectionSectionViewModel(title: "Informant Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: "Name",
                                                                              value: "Emily Quentin",
                                                                              width: .column(3)),
                                                
                                                IncidentOverviewItemViewModel(title: "Contact Number",
                                                                              value: "9000 0000",
                                                                              width: .column(3)),
            ]),
            
            CADFormCollectionSectionViewModel(title: "Incident Details",
                                              items: [
                                                IncidentOverviewItemViewModel(title: nil,
                                                                              value: "An armed group of men are currently barricaded within the lobby of Orion Central Bank. Initial communication has not been established and the current situation is approaching a critical level.",
                                                                              width: .column(1)),
            ])
        ]
    }()
    
    /// The title to use in the navigation bar
    open func navTitle() -> String {
        return NSLocalizedString("Overview", comment: "Overview sidebar title")
    }
}

