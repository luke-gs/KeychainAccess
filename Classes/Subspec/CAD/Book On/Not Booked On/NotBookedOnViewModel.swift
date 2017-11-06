//
//  NotBookedOnViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class NotBookedOnViewModel: CADFormCollectionViewModel<NotBookedOnItemViewModel> {
    
    public override init() {
        super.init()
        
        sections = [
            CADFormCollectionSectionViewModel(title: "Patrol Area",
                                              items: [
                                                NotBookedOnItemViewModel(title: "Collingwood",
                                                                         subtitle: "9 Callsigns",
                                                                         image:  AssetManager.shared.image(forKey: .location),
                                                                         imageColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1),
                                                                         imageBackgroundColor: nil)
                ]
            ),
            
            CADFormCollectionSectionViewModel(title: "Recently Used Callsigns",
                                              items: [
                                                NotBookedOnCallsignItemViewModel(callsign: "B14",
                                                                                 status: "Off Duty",
                                                                                 location: "Collingwood Station",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1),
                                                                                 imageBackgroundColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "P24",
                                                                                 status: "Off Duty",
                                                                                 location: "Collingwood Station",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1),
                                                                                 imageBackgroundColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "K94",
                                                                                 status: "On Air",
                                                                                 location: "Each Richmond",
                                                                                 image: AssetManager.shared.image(forKey: .resourceDog),
                                                                                 imageColor: .black,
                                                                                 imageBackgroundColor: #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
                                                )
                ]
            )
        ]
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return NotBookedOnViewController(viewModel: self)
    }

    /// Create the book on view controller for a selected callsign
    open func bookOnViewControllerForItem(_ indexPath: IndexPath) -> UIViewController? {
        if let itemViewModel = item(at: indexPath) as? NotBookedOnCallsignItemViewModel {
            return BookOnDetailsFormViewModel(callsignViewModel: itemViewModel).createViewController()
        }
        return nil
    }
    
    open func headerText() -> String? {
        return NSLocalizedString("You are not viewing all active tasks and resources.\nOnly booked on users can respond to tasks.", comment: "")
    }
    
    open func stayOffDutyButtonText() -> String? {
        return NSLocalizedString("Stay Off Duty", comment: "")
    }
    
    open func allCallsignsButtonText() -> String? {
        return NSLocalizedString("View All Callsigns", comment: "")
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
    
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }
    
}
