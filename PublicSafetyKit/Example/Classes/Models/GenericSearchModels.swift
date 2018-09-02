//
//  GenericSearchModels.swift
//  MPOLKitDemo
//
//  Created by Pavel Boryseiko on 31/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//



// MARK: Generic Search Demo searchables

struct Test: CustomSearchDisplayable {
    var title: String? = "James"
    var subtitle: String? = "Neverdie"
    var section: String? = "On Duty"
    var image: UIImage? = UIImage(named: "SidebarAlert")!


    func contains(_ searchText: String) -> Bool {
        return title?.starts(with: searchText) ?? false
    }
}

struct Test2: CustomSearchDisplayable {
    var title: String? = "Herli"
    var subtitle: String? //= "Chad"
    var section: String? //= "On Air"
    var image: UIImage? = UIImage(named: "SidebarAlert")!

    func contains(_ searchText: String) -> Bool {
        return title?.starts(with: searchText) ?? false
    }
}

struct Test3: CustomSearchDisplayable {
    var title: String? = "Luke"
    var subtitle: String? = "Jimmy Boy"
    var section: String? = "Duress"
    var image: UIImage? = UIImage(named: "SidebarAlertFilled")!

    func contains(_ searchText: String) -> Bool {
        return (title?.starts(with: searchText) ?? false) || (subtitle?.contains(searchText) ?? false)
    }
}
