//
//  CallsignListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListViewModel: CADFormCollectionViewModel<NotBookedOnCallsignItemViewModel> {
    
    private var data: [CADFormCollectionSectionViewModel<NotBookedOnCallsignItemViewModel>] = {
        return [
            CADFormCollectionSectionViewModel(title: "2 Off Duty",
                                              items: [
                                                NotBookedOnCallsignItemViewModel(callsign: "B14",
                                                                                 status: "Off Duty",
                                                                                 location: "Collingwood Station",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "P24",
                                                                                 status: "Off Duty",
                                                                                 location: "Collingwood Station",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "P29",
                                                                                 status: "Off Duty",
                                                                                 location: "Collingwood Station",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                ]
            ),
            
            CADFormCollectionSectionViewModel(title: "6 Booked On",
                                              items: [
                                                NotBookedOnCallsignItemViewModel(callsign: "K94 (1)",
                                                                                 status: "On Air",
                                                                                 location: "Each Richmond",
                                                                                 image: AssetManager.shared.image(forKey: .resourceDog),
                                                                                 imageColor: #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "P03 (3)",
                                                                                 status: "At Incident",
                                                                                 location: "Fitzroy",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                                                 // badgeText: "P3",
                                                    // badgeTextColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1),
                                                    // badgeBorderColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "P12 (1)",
                                                                                 status: "At Incident",
                                                                                 location: "Collingwood",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                                                 // badgeText: "P2",
                                                    // badgeTextColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                                    // badgeFillColor: #colorLiteral(red: 0.9960784314, green: 0.7960784314, blue: 0.1843137255, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "P17 (2)",
                                                                                 status: "At Incident",
                                                                                 location: "Richmond",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                                                 // badgeText: "P2",
                                                    // badgeTextColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                                    // badgeFillColor: #colorLiteral(red: 0.9960784314, green: 0.7960784314, blue: 0.1843137255, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "P14 (3)",
                                                                                 status: "At Incident",
                                                                                 location: "Abbotsford",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                                                 // badgeText: "P3",
                                                    // badgeTextColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1),
                                                    // badgeBorderColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
                                                ),
                                                NotBookedOnCallsignItemViewModel(callsign: "B18 (2)",
                                                                                 status: "On Air",
                                                                                 location: "North Richmond",
                                                                                 image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                 imageColor: #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
                                                ),
                                                ]
            )
        ]
    }()
    
    public override init() {
        super.init()
        
        sections = data
    }
    
    /// Create the book on view controller for a selected callsign
    open func bookOnViewControllerForItem(_ indexPath: IndexPath) -> UIViewController? {
        if let itemViewModel = item(at: indexPath) {
            return BookOnDetailsFormViewModel(callsignViewModel: itemViewModel).createViewController()
        }
        return nil
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> CallsignListViewController {
        return CallsignListViewController(viewModel: self)
    }
    
    /// The subtitle to use in the navigation bar
    open func navSubtitle() -> String? {
        return NSLocalizedString("Melbourne", comment: "") // TODO: Get from somewhere else
    }
    
    // MARK: - Override
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("All Callsigns", comment: "All Callsigns title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Callsigns Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }
    
    
    /// Applies the search filter with the specified text, and updates the `sections`
    /// array to match. If no results found, an empty array will be set for `sections`.
    open func applyFilter(withText text: String?) {
        guard let text = text, text.count > 0 else {
            sections = data
            return
        }
        
        // Map sections
        let filteredData = (data.map { section in
            // Map items
            let filteredItems = (section.items.map { item in
                // Map if title contains case-insensitive match
                if item.title.lowercased().contains(text.lowercased()) {
                    return item
                }
                return nil
            } as [NotBookedOnCallsignItemViewModel?]).removeNils()
            
            // Return the section if items were found
            if filteredItems.count > 0 {
                return CADFormCollectionSectionViewModel(title: section.title, items: filteredItems)
            }
            
            return nil
        } as [CADFormCollectionSectionViewModel<NotBookedOnCallsignItemViewModel>?]).removeNils()
        
        sections = filteredData
    }
}
