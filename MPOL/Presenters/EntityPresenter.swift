//
//  EntityPresenter.swift
//  MPOL
//
//  Created by KGWH78 on 11/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit


public enum EntityScreen: Presentable {

    case help(type: EntityType)

    case createEntity(type: EntityType)

    case entityDetails(entity: Entity)

    public enum EntityType {
        case person, vehicle, organisation, location
    }

}


public class EntityPresenter: Presenter {

    public init() {}

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        guard let presentable = presentable as? EntityScreen else { return UIViewController() }

        switch presentable {

        case .entityDetails(let entity):
            let dataSource: EntityDetailSectionsDataSource

            if entity is Person {
                dataSource = PersonDetailsSectionsDataSource(baseEntity: entity)
            } else {
                dataSource = VehicleDetailsSectionsDataSource(baseEntity: entity)
            }

            return EntityDetailSplitViewController(dataSource: dataSource)

        case .help(let type):
            let title: String
            let items: [SearchHelpSection]

            switch type {
            case .person:
                title = "Searching for People"
                items = [
                    SearchHelpSection(title: "The default search order", detail: .tags(["Last Name", ",", "Given Name", "Middle Name/s", "DOB/Age Range"])),
                    SearchHelpSection(title: "General conditions", detail: .text("Search is NOT case sensetive\nLast name is required\nYou can use partial names or initials for given and middle names\nNames can contain apostrophes or hyphens")),
                    SearchHelpSection(title: "Optional", detail: .text("Given Name, Middle Name 1, Middle Name 2, DOB/Age Range")),
                    SearchHelpSection(title: "Use a comma to separate Last Names that contain spaces or hyphens", detail: .text("de Jaager, Jesse\nLe-Gall, Léa")),
                    SearchHelpSection(title: "Searching for Date of Birth, Age and Age Ranges", detail: .text("Parker Hunter 15/06/1985\nParker Hunter 06/1986\nParker Hunter 1985\nParker Hunter 32\nParker Hunter 30-35")),
                    SearchHelpSection(title: "Searching for Aliases", detail: .text("@ Parker Hunter")),
                    SearchHelpSection(title: "More Examples", detail: .text("Parker Hunter S\nParker Hunter S 32"))
                ]
            case .vehicle:
                title = NSLocalizedString("Searching for Vehicles", comment: "")
                items = []
            case .location:
                title = NSLocalizedString("Searching for Locations", comment: "")
                items = []
            case .organisation:
                title = NSLocalizedString("Searching for Organisations", comment: "")
                items = []
            }

            let helpViewController = SearchHelpViewController(items: items)
            helpViewController.title = title
            helpViewController.view.backgroundColor = .white
            return helpViewController

        case .createEntity(let type):
            let title: String

            switch type {
            case .person:
                title = NSLocalizedString("New Person", comment: "")
            case .vehicle:
                title = NSLocalizedString("New Vehicle", comment: "")
            case .location:
                title = NSLocalizedString("New Location", comment: "")
            case .organisation:
                title = NSLocalizedString("New Organisation", comment: "")
            }

            let viewController = UIViewController()
            viewController.title = title
            viewController.view.backgroundColor = .white
            return viewController
            
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        from.show(to, sender: from)
    }


    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is EntityScreen.Type
    }

}
