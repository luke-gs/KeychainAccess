//
//  NotBookedOnViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class NotBookedOnViewModel: CADFormCollectionViewModel<NotBookedOnItem> {
    
    /// Create the view controller for this view model
    public func createViewController() -> NotBookedOnViewController {
        return NotBookedOnViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    private lazy var data: [CADFormCollectionSectionViewModel<NotBookedOnItem>] = {
        return [
            CADFormCollectionSectionViewModel(title: "Patrol Area",
                                              items: [
                                                NotBookedOnItem(title: "Collingwood",
                                                                subtitle: "9 Callsigns",
                                                                image: AssetManager.shared.image(forKey: .radioButtonSelected)) // TODO: Get real image
                ]),
            
            CADFormCollectionSectionViewModel(title: "Recently Used Callsigns",
                                              items: [
                                                NotBookedOnItem(title: "B14",
                                                                subtitle: "Collingwood Station  :  Off Duty",
                                                                image: AssetManager.shared.image(forKey: .resourceCar)),
                                                NotBookedOnItem(title: "P24",
                                                                subtitle: "Collingwood Station  :  Off Duty",
                                                                image: AssetManager.shared.image(forKey: .resourceCar)),
                                                NotBookedOnItem(title: "P29",
                                                                subtitle: "Collingwood Station  :  Off Duty",
                                                                image: AssetManager.shared.image(forKey: .resourceCar)),
                                                NotBookedOnItem(title: "K94 (1)",
                                                                subtitle: "Each Richmond  :  On Air",
                                                                image: AssetManager.shared.image(forKey: .resourceDog))
                ])
        ]
    }()
    
    
    func headerText() -> String? {
        return NSLocalizedString("You are not viewing all active tasks and resources.\nOnly booked on users can respond to tasks.", comment: "")
    }
    
    func stayOffDutyButtonText() -> String? {
        return NSLocalizedString("Stay Off Duty", comment: "").uppercased()
    }
    
    func allCallsignsButtonText() -> String? {
        return NSLocalizedString("View All Callsigns", comment: "").uppercased()
    }
    
    
    
    // MARK: - Override
    
    override open func sections() -> [CADFormCollectionSectionViewModel<NotBookedOnItem>] {
        return data
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("You are not booked on", comment: "Not Booked On title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Callsigns Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }
    
}
