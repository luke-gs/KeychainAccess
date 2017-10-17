//
//  NotBookedOnViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class NotBookedOnViewModel: CADFormCollectionViewModel<NotBookedOnItem> {
    
    public override init() {
        super.init()
        sections = [
            CADFormCollectionSectionViewModel(title: "Patrol Area",
                                              items: [
                                                NotBookedOnItem(title: "Collingwood",
                                                                subtitle: "9 Callsigns",
                                                                image: AssetManager.shared.image(forKey: .radioButtonSelected),
                                                                imageColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)) // TODO: Get real image
                ]
            ),
            
            CADFormCollectionSectionViewModel(title: "Recently Used Callsigns",
                                              items: [
                                                NotBookedOnItem(title: "B14",
                                                                subtitle: "Collingwood Station  :  Off Duty",
                                                                image: AssetManager.shared.image(forKey: .resourceCar),
                                                                imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                NotBookedOnItem(title: "P24",
                                                                subtitle: "Collingwood Station  :  Off Duty",
                                                                image: AssetManager.shared.image(forKey: .resourceCar),
                                                                imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                NotBookedOnItem(title: "P29",
                                                                subtitle: "Collingwood Station  :  Off Duty",
                                                                image: AssetManager.shared.image(forKey: .resourceCar),
                                                                imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                NotBookedOnItem(title: "K94 (1)",
                                                                subtitle: "Each Richmond  :  On Air",
                                                                image: AssetManager.shared.image(forKey: .resourceDog),
                                                                imageColor: #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
                                                )
                ]
            )
        ]
    }
    
    /// Create the view controller for this view model
    public func createViewController() -> NotBookedOnViewController {
        return NotBookedOnViewController(viewModel: self)
    }
    
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
