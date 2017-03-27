//
//  OrganizationInfoViewController.swift
//  Pods
//
//  Created by Rod Brown on 27/3/17.
//
//

import UIKit

open class OrganizationInfoViewController: EntityInfoViewController {

    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CollectionViewFormSubtitleCell.self)
    }
    
    
    
    // MARK: - Enums
    
    private enum Section: Int {
        case header
        case details
        case aliases
        
        static let count = 3
        
        var localizedTitle: String {
            switch self {
            case .header:  return NSLocalizedString("LAST UPDATED",          bundle: .mpolKit, comment: "")
            case .details: return NSLocalizedString("BUSINESS/ORGANISATION", bundle: .mpolKit, comment: "")
            case .aliases: return NSLocalizedString("ALIASES",               bundle: .mpolKit, comment: "")
            }
        }
    }
    
}
