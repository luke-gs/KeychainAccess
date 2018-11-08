//
//  OfficerSearchSectionViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class OfficerSearchSectionViewModel {

    var items: [Officer]
    var title: String

    init(items: [Officer], title: String) {
        self.items = items
        self.title = title
    }
}
