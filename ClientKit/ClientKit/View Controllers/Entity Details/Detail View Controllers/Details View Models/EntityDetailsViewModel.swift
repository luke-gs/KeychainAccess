//
//  PersonDetailsViewModel.swift
//  MPOLKit
//
//  Created by RUI WANG on 4/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// A base viewModel to provide generic implementation
public class EntityDetailsViewModel<T>: EntityDetailsViewModelable {
    
    /// Generic section type
    public typealias DetailsType = T
    
    /// A delegate for update UI
    weak public var delegate: EntityDetailsViewModelDelegate?
    
    public var person: Person? {
        didSet {

        }
    }
    
    public var sections: [DetailsType]? {
        didSet {
            let count = sections?.count ?? 0
            delegate?.updateSidebarItemCount(UInt(count))
            
            let state: LoadingStateManager.State  = sections!.isEmpty ? .noContent : .loaded
            delegate?.updateLoadingState(state)
            delegate?.reloadData()
        }
    }
    
    /// A generic section header for collectionView
    /// Subclass needs override to provide custom title
    public var sectionHeader: String? {
        let count = numberOfItems()
        
        if count > 0 {
            let baseString = count > 1 ? NSLocalizedString("%d ITEMS", bundle: .mpolKit, comment: "") : NSLocalizedString("%d ITEM", bundle: .mpolKit, comment: "")
            return String(format: baseString, count)
        }
        return nil
    }
    
}
