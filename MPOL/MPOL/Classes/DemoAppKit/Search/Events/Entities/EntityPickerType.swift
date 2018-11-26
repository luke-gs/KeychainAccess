//
//  EntityPickerType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit

/// Enumeration that defines various entity pickers.
public enum EntityPickerType {
    case involvement
    case additionalAction
    case viewRecord
}

/// Protocol for defining the implementation action to be performed within the EntityListViewController.
public protocol EntityPickerTypeDefiniton {

    /// The instance of the DefaultEntitiesListViewController that requires this action. Required for initiating content reloads etc.
    var context: DefaultEntitiesListViewController {get set}

    // The entity that objects that are picked will be applied to.
    var entity: MPOLKitEntity { get }

    /// The data source to be used when presenting the CustomPickerController.
    var dataSource: CustomSearchPickerDataSource {get}

    /// The completionHandler to be executed when the user has selected their required item(s) and selected "Done".
    var completion: ((CustomPickerController, IndexSet) -> Void)? {get}
}

/// Struct with the definition for picking involvements for an Entity.
internal struct InvolvementPickerDefinition: EntityPickerTypeDefiniton {

    var context: DefaultEntitiesListViewController
    var entity: MPOLKitEntity

    init(for context: DefaultEntitiesListViewController, with entity: MPOLKitEntity) {
        self.context = context
        self.entity = entity
    }

    var dataSource: CustomSearchPickerDataSource {
        let displayable = context.viewModel.displayable(for: entity)
        let headerConfig = SearchHeaderConfiguration(title: displayable.title?.sizing().string,
                                                     subtitle: "No Involvements Selected",
                                                     image: displayable.thumbnail(ofSize: .small),
                                                     imageStyle: .entity,
                                                     tintColor: displayable.iconColor,
                                                     borderColor: displayable.borderColor)

        let dataSource = DefaultPickableSearchDataSource(objects: context.viewModel.involvements(for: entity),
                                                         selectedObjects: context.viewModel.retrieveInvolvements(for: entity) ?? [],
                                                         title: "Involvements",
                                                         dismissOnFinish: context.viewModel.entities.contains(entity),
                                                         configuration: headerConfig)
        dataSource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))
        if let selectedObjects = dataSource.selectedObjects, !selectedObjects.isEmpty {
            dataSource.updateHeader(for: selectedObjects)
        }
        return dataSource
    }

    var completion: ((CustomPickerController, IndexSet) -> Void)? {
        return { controller, indexes in
            let context = self.context
            var viewModel = context.viewModel
            let involvements = controller.objects.enumerated()
            .filter({ indexes.contains($0.offset) })
            .compactMap({ $0.element as? String })

            let isEditingEntity = viewModel.entities.contains(self.entity)

            if isEditingEntity {
                viewModel.update(involvements, for: self.entity)
                context.updateLoadingManager()
                context.reloadForm()
                context.dismissAnimated()
            } else {
                viewModel.selectedInvolvements = involvements
                if !viewModel.additionalActions(for: self.entity).isEmpty {
                    context.presentPickerViewController(type: .additionalAction, entity: self.entity)
                } else {
                    viewModel.addEntity(self.entity, with: context.viewModel.selectedInvolvements, and: nil)
                    context.updateLoadingManager()
                    context.reloadForm()
                    context.dismissAnimated()
                }
            }
        }
    }
}

/// Struct with the definition for picking additional actions for an Entity.
internal struct AdditionalActionPickerDefinition: EntityPickerTypeDefiniton {

    var context: DefaultEntitiesListViewController
    var entity: MPOLKitEntity

    init(for context: DefaultEntitiesListViewController, with entity: MPOLKitEntity) {
        self.context = context
        self.entity = entity
    }

    var dataSource: CustomSearchPickerDataSource {
        let displayable = context.viewModel.displayable(for: entity)
        let headerConfig = SearchHeaderConfiguration(title: displayable.title?.sizing().string,
                                                     subtitle: "No Additional Actions Selected",
                                                     image: displayable.thumbnail(ofSize: .small),
                                                     imageStyle: .entity,
                                                     tintColor: displayable.iconColor,
                                                     borderColor: displayable.borderColor)

        let selectedObjects = context.viewModel.retrieveAdditionalActions(for: entity)?.compactMap { $0.additionalActionType.rawValue } ?? []
        let dataSource = DefaultPickableSearchDataSource(objects: context.viewModel.additionalActions(for: entity),
                                                         selectedObjects: selectedObjects,
                                                         title: "Additional Actions",
                                                         requiresSelection: false,
                                                         configuration: headerConfig)
        dataSource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))
        if let selectedObjects = dataSource.selectedObjects, !selectedObjects.isEmpty {
            dataSource.updateHeader(for: selectedObjects)
        }
        return dataSource
    }

    var completion: ((CustomPickerController, IndexSet) -> Void)? {
        return { controller, indexes in
            let context = self.context
            let entity = self.entity
            var viewModel = context.viewModel

            let actionTypes = controller.objects.enumerated()
                .filter({ indexes.contains($0.offset) })
                .compactMap({ AdditionalActionType(rawValue: $0.element.title!.sizing().string) })

            let actions = actionTypes.map { AdditionalAction(incident: viewModel.report.incident!, type: $0) }

            let isEditingEntity = viewModel.entities.contains(entity)

            if isEditingEntity {
                if actionTypes != context.viewModel.retrieveAdditionalActions(for: entity)?.compactMap({ $0.additionalActionType}) {
                    viewModel.updateActions(for: entity, with: actions)
                }
            } else {
                viewModel.addEntity(entity, with: viewModel.selectedInvolvements, and: actions)
            }

            context.updateLoadingManager()
            context.reloadForm()
            context.dismissAnimated()
        }
    }
}
