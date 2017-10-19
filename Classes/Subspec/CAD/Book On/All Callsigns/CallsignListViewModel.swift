//
//  CallsignListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CallsignListViewModel: CADFormCollectionViewModel<CallsignListItemViewModel> {
    
    private var data: [CADFormCollectionSectionViewModel<CallsignListItemViewModel>] = {
        return [
            CADFormCollectionSectionViewModel(title: "2 Off Duty",
                                              items: [
                                                CallsignListItemViewModel(title: "B14",
                                                                          subtitle: "Collingwood Station  :  Off Duty",
                                                                          image: AssetManager.shared.image(forKey: .resourceCar),
                                                                          imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                CallsignListItemViewModel(title: "P24",
                                                                          subtitle: "Collingwood Station  :  Off Duty",
                                                                          image: AssetManager.shared.image(forKey: .resourceCar),
                                                                          imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                                CallsignListItemViewModel(title: "P29",
                                                                          subtitle: "Collingwood Station  :  Off Duty",
                                                                          image: AssetManager.shared.image(forKey: .resourceCar),
                                                                          imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)
                                                ),
                                            ]
            ),
            
            CADFormCollectionSectionViewModel(title: "6 Booked On",
                                              items: [
                                                CallsignListItemViewModel(title: "K94 (1)",
                                                                          subtitle: "Each Richmond  :  On Air",
                                                                          image: AssetManager.shared.image(forKey: .resourceDog),
                                                                          imageColor: #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
                                                ),
                                                CallsignListItemViewModel(title: "P03 (3)",
                                                                          subtitle: "Fitzroy  :  At Incident",
                                                                          image: AssetManager.shared.image(forKey: .resourceCar),
                                                                          imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1),
                                                                          badgeText: "P3",
                                                                          badgeTextColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1),
                                                                          badgeBorderColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
                                                ),
                                                CallsignListItemViewModel(title: "P12 (1)",
                                                                          subtitle: "Collingwood  :  At Incident",
                                                                          image: AssetManager.shared.image(forKey: .resourceCar),
                                                                          imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1),
                                                                          badgeText: "P2",
                                                                          badgeTextColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                                                          badgeFillColor: #colorLiteral(red: 0.9960784314, green: 0.7960784314, blue: 0.1843137255, alpha: 1)
                                                ),
                                                CallsignListItemViewModel(title: "P17 (2)",
                                                                          subtitle: "Richmond  :  At Incident",
                                                                          image: AssetManager.shared.image(forKey: .resourceCar),
                                                                          imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1),
                                                                          badgeText: "P2",
                                                                          badgeTextColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                                                          badgeFillColor: #colorLiteral(red: 0.9960784314, green: 0.7960784314, blue: 0.1843137255, alpha: 1)
                                                ),
                                                CallsignListItemViewModel(title: "P14 (3)",
                                                                          subtitle: "Abbotsford  :  At Incident",
                                                                          image: AssetManager.shared.image(forKey: .resourceCar),
                                                                          imageColor: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1),
                                                                          badgeText: "P3",
                                                                          badgeTextColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1),
                                                                          badgeBorderColor: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1)
                                                ),
                                                CallsignListItemViewModel(title: "B18 (2)",
                                                                          subtitle: "North Richmond  :  On Air",
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
    
    open func applyFilter(withText text: String?) {
        guard let text = text, text.count > 0 else {
            sections = data
            return
        }
        
        // Map sections
        let filteredData = (data.map { section in
            // Map items
            let filteredItems = (section.items.map { item in
                // Map if case-insensitive match
                if item.title.lowercased().contains(text.lowercased()) {
                    return item
                }
                return nil
            } as [CallsignListItemViewModel?]).removeNils()
            
            // Return the section if items were found
            if filteredItems.count > 0 {
                return CADFormCollectionSectionViewModel(title: section.title, items: filteredItems)
            }
            
            return nil
        } as [CADFormCollectionSectionViewModel<CallsignListItemViewModel>?]).removeNils()
        
        sections = filteredData
    }
}
