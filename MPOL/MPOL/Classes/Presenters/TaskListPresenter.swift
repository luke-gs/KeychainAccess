//
//  TaskListPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import DemoAppKit
import PromiseKit

public class TaskListPresenter: Presenter {

    public var tasksSplitViewModel: TasksSplitViewModel!
    public var tasksSplitViewController: UIViewController!

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! TaskListScreen

        switch presentable {

        case .landing:
            // Create dependent view models
            let listViewModel = TasksListViewModel()
            let listHeaderViewModel = TasksListHeaderViewModel()
            let listContainerViewModel = TasksListContainerViewModel(headerViewModel: listHeaderViewModel, listViewModel: listViewModel)
            let mapViewModel = TasksMapViewModel()
            let mapFilterViewModel = TasksMapFilterViewModelCore()

            // Create split view model
            tasksSplitViewModel = TasksSplitViewModel(listContainerViewModel: listContainerViewModel,
                                                          mapViewModel: mapViewModel,
                                                          filterViewModel: mapFilterViewModel)

            tasksSplitViewController = tasksSplitViewModel.createViewController()
            return tasksSplitViewController

        case .createIncident:
            
            let priorityOptions = CADClientModelTypes.incidentGrade.allCases.map { $0.rawValue }
            let primaryCodeOptions = CADStateManager.shared.manifestEntries(for: .incidentType).rawValues()
            
            // Populate status in the form
            let statusItems = CADClientModelTypes.resourceStatus?.incidentCases
            let selectedStatus = CADClientModelTypes.resourceStatus?.defaultCreateCase
            
            // Submit action
            let submitHandler: CreateTaskViewModel.CreateTaskSubmitHandler = { createTaskViewModel in
                // TODO: implement handler
                /**
                 form values:
                 createTaskViewModel.selectedStatus
                 createTaskViewModel.priority
                 createTaskViewModel.primaryCode
                 createTaskViewModel.remarks
                */
                return Promise<Void>()
            }
            
            let viewModel = CreateTaskViewModel(priorityOptions: priorityOptions,
                                            primaryCodeOptions: primaryCodeOptions,
                                            statusHeader: NSLocalizedString("Initial Status", comment: ""),
                                            statusItems: statusItems,
                                            selectedStatus: selectedStatus,
                                            submitHandler: submitHandler)
            
            
            return CreateTaskViewController(viewModel: viewModel)

        case .mapFilter(let delegate):
            return tasksSplitViewModel.filterViewModel.createViewController(delegate: delegate)

        case .clusterDetails(let annotationView, let delegate):
            return ClusterTasksViewModelCore(annotationView: annotationView).createViewController(delegate: delegate)
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! TaskListScreen

        switch presentable {

        // Present form sheet
        case .mapFilter:
            from.presentFormSheet(to, animated: true)

        case .clusterDetails(let annotationView, _):
            // Present popover (hidden nav bar)
            let nav = PopoverNavigationController(rootViewController: to)
            nav.modalPresentationStyle = .popover
            nav.popoverPresentationController?.sourceView = annotationView
            nav.popoverPresentationController?.sourceRect = annotationView.bounds
            nav.popoverPresentationController?.permittedArrowDirections = [.left, .right]
            from.present(nav, animated: true, completion: nil)

        // Default presentation, based on container class (eg push if in navigation controller)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskListScreen.Type
    }

}
