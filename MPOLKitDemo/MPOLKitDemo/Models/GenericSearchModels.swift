//
//  GenericSearchModels.swift
//  MPOLKitDemo
//
//  Created by Pavel Boryseiko on 31/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

// MARK: Generic Search Demo searchables

struct Test: GenericSearchable {
    var title: String = "James"
    var subtitle: String? = "Neverdie"
    var section: String? = "On Duty"
    var image: UIImage? = UIImage(named: "SidebarAlert")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString)
    }
}

struct Test2: GenericSearchable {
    var title: String = "Herli"
    var subtitle: String? //= "Chad"
    var section: String? //= "On Air"
    var image: UIImage? = UIImage(named: "SidebarAlert")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString)
    }
}

struct Test3: GenericSearchable {
    var title: String = "Luke"
    var subtitle: String? = "Jimmy Boy"
    var section: String? = "Duress"
    var image: UIImage? = UIImage(named: "SidebarAlertFilled")!

    func matches(searchString: String) -> Bool {
        return title.starts(with: searchString) || (subtitle?.contains(searchString) ?? false)
    }
}
