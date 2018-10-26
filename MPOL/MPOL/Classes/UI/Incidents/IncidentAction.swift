//
//  IncidentAction.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

/// Enumeration that defines various Incident-based actions that can be performed.
public enum IncidentActionType {
    case add
    case choosePrimary
    case deletePrimary
}

/// Protocol for defining the implementation action to be performed within the IncidentListController.
protocol IncidentActionDefiniton {
    init(for context: IncidentListViewController)

    /// The instance of the IncidentListViewController that requires this action. Required for initiating content reloads etc.
    var context: IncidentListViewController? {get set}

    /// The dataSource to be used when presenting the CustomPickerController.
    var dataSource: CustomSearchPickerDataSource {get}

    /// The completionHandler to be executed when the user has selected their required item(s) and selected "Done".
    var completion: ((CustomPickerController, IndexSet) -> Void)? {get}

    /// Determines whether or not the user can select multiple items when executing this action.
    var canSelectMultiple: Bool {get}
}

/// Struct with the definition for adding an Incident.
struct AddIncidentDefinition: IncidentActionDefiniton {

    weak var context: IncidentListViewController?

    init(for context: IncidentListViewController) {
        self.context = context
    }

    var dataSource: CustomSearchPickerDataSource {
        if let context = context {
            let headerConfig = SearchHeaderConfiguration(title: context.viewModel.searchHeaderTitle(),
                                                         subtitle: "",
                                                         image: AssetManager.shared.image(forKey: .iconPencil)?
                                                            .withCircleBackground(tintColor: .white,
                                                                                  circleColor: .primaryGray,
                                                                                  style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                                padding: .zero)),
                                                         imageStyle: .circle)

            let dataSource = IncidentSearchDataSource(objects: IncidentType.allIncidentTypes().map { $0.rawValue },
                                                      configuration: headerConfig)

            dataSource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

            return dataSource
        } else {
            fatalError("Context was not found")
        }
    }

    var completion: ((CustomPickerController, IndexSet) -> Void)? {
        if let context = context {
            return { controller, index in
                let incidents = controller.objects.enumerated().filter { index.contains($0.offset) }.compactMap { $0.element.title?.sizing().string }
                context.viewModel.add(incidents)
                context.updateLoadingManager()
                context.reloadForm()
            }
        } else {
            fatalError("Context was not found")
        }
    }

    var canSelectMultiple: Bool {
        return true
    }
}

/// Struct with the definition for choosing the Primary Incident.
struct ChoosePrimaryIncidentDefinition: IncidentActionDefiniton {

    weak var context: IncidentListViewController?

    init(for context: IncidentListViewController) {
        self.context = context
    }

    var dataSource: CustomSearchPickerDataSource {
        if let context = context {

            let dataSource = DefaultSearchDataSource(objects: context.viewModel.incidentList.map {$0.title!},
                                                     selectedObjects: [(context.viewModel.primaryIncident?.title!)!],
                                                     title: "Select Primary Incident")
            dataSource.header = CustomisableSearchHeaderView()
            return dataSource
        } else {
            fatalError("Context was not found")
        }
    }

    var completion: ((CustomPickerController, IndexSet) -> Void)? {
        if let context = context {
            return { controller, indexes in
                //Without the ".first", incident should still have a count of one 1, but it's there in case
                let incidentTitle = controller.objects.enumerated()
                    .filter({ indexes.contains($0.offset) }).first?.element

                let index = context.viewModel.incidentList.enumerated().first(where: {
                    return $0.element.title?.sizing() == incidentTitle?.title?.sizing()
                })?.offset

                if let index = index {
                    context.viewModel.changePrimaryIncident(index)
                    context.reloadForm()
                    context.dismissAnimated()
                }
            }
        } else {
            fatalError("Context was not found")
        }
    }

    var canSelectMultiple: Bool {
        return false
    }
}

/// Struct with the definition for deleting the Primary Incident.
struct DeletePrimaryIncidentDefinition: IncidentActionDefiniton {

    weak var context: IncidentListViewController?

    init(for context: IncidentListViewController) {
        self.context = context
    }

    var dataSource: CustomSearchPickerDataSource {
        if let context = context {
            let dataSource = DefaultSearchDataSource(objects: context.viewModel.additionalIncidents!.map {$0.title!},
                                                     title: "Select New Primary Incident")
            dataSource.header = CustomisableSearchHeaderView()

            return dataSource
        } else {
            fatalError("Context was not found")
        }
    }

    var completion: ((CustomPickerController, IndexSet) -> Void)? {
        if let context = context {
            return { controller, indexes in
                //Without the ".first", incident should still have a count of one 1, but it's there in case
                let incidentTitle = controller.objects.enumerated()
                    .filter({ indexes.contains($0.offset) }).first?.element

                let index = context.viewModel.incidentList.enumerated().first(where: {
                    return $0.element.title?.sizing() == incidentTitle?.title?.sizing()
                })?.offset

                if let index = index {
                    context.viewModel.changePrimaryIncident(index)
                    //remove the primary incident once the new one has been chosen, which will be the first in additional
                    context.viewModel.removeIncident(context.viewModel.incident(for: (context.viewModel.additionalIncidents?.first)!)!)
                    context.reloadForm()
                    context.dismissAnimated()
                }
            }
        } else {
            fatalError("Context was not found")
        }
    }

    var canSelectMultiple: Bool {
        return false
    }
}
