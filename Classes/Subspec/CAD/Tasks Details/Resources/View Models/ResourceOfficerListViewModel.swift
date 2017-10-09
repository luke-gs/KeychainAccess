//
//  ResourceOfficerListViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOfficerListViewModel {

    private var officers: [ResourceOfficerViewModel] = []
    
    /// Number of cells to display
    public func numberOfItems() -> Int {
        return officers.count
    }
    
    /// Title for cell at index path
    public func item(at indexPath: IndexPath) -> ResourceOfficerViewModel? {
        guard indexPath.row < officers.count else { return nil }
        return officers[indexPath.row]
    }
}

// MARK: - Dummy data
extension ResourceOfficerListViewModel {
    public func loadDummyData() {
        officers += [
            ResourceOfficerViewModel(title: "Dean McCrae", subtitle: "Senior Constable  :  #820904  :  Gold License", badgeText: "DRIVER"),
            ResourceOfficerViewModel(title: "Sarah Worrall", subtitle: "Constable  :  #800560  :  Silver License", badgeText: nil),
        ]
    }
}
