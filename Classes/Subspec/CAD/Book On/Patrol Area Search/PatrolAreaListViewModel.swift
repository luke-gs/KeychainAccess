//
//  PatrolAreaListViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

public class PatrolAreaListViewModel: GenericSearchDefaultViewModel {
    
    // MARK: - Setup
    
    public convenience init() {
        var items: [GenericSearchable] = []
        for patrolArea in CADStateManager.shared.patrolGroups() {
            if let title = patrolArea.title {
                let viewModel = PatrolAreaListItemViewModel(patrolArea: title)
                items.append(viewModel)
            }
        }
        
        self.init(items: items)
    }
    
    public required init(items: [GenericSearchable]) {
        super.init(items: items)
        title = NSLocalizedString("Patrol Area", comment: "")
    }
    
    open func createViewController() -> PatrolAreaListViewController {
        return PatrolAreaListViewController(viewModel: self)
    }
    
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Patrol Areas Found", comment: "")
    }
    
}
