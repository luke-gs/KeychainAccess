//
//  PatrolAreaListViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

public class PatrolAreaListViewModel: GenericSearchDefaultViewModel {
    
    // MARK: - Properties
    
    public var selectedPatrolArea: String?
    public private(set) var items: [PatrolAreaListItemViewModel] = []
    
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
        hasSections = false
        
        self.items = items as? [PatrolAreaListItemViewModel] ?? []
    }
    
    open func createViewController() -> PatrolAreaListViewController {
        return PatrolAreaListViewController(viewModel: self)
    }
    
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Patrol Areas Found", comment: "")
    }
    
    open override func accessory(for indexPath: IndexPath) -> ItemAccessory? {
        if let selected = selectedPatrolArea {
            let patrolArea = items[indexPath.row].patrolArea
            return patrolArea == selected ? ItemAccessory.checkmark : nil
        }
        
        return nil
    }
    
}
