//
//  OrganisationInfoViewModel.swift
//  ClientKit
//
//  Created by Megan Efron on 11/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

open class OrganisationInfoViewModel: EntityDetailFormViewModel {

    // MARK: - EntityDetailFormViewModel
    
    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {
        // TODO: - Finish when data is available
    }
    
    open override var title: String? {
        return NSLocalizedString("Information", comment: "")
    }
    
    open override var noContentTitle: String? {
        return NSLocalizedString("No Organisation Found", comment: "")
    }
    
    open override var noContentSubtitle: String? {
        return NSLocalizedString("There are no details for this organisation", comment: "")
    }
    
    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .info)
    }
}
