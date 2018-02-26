//
//  TaskListPresenter.swift
//  CAD
//
//  Created by Trent Fitzgibbon on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class TaskListPresenter: Presenter {

    var tasksSplitViewModel: TasksSplitViewModel!

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! TaskListScreen

        switch presentable {
        case .splitView:
            // Create dependent view models
            let listViewModel = TasksListViewModel()
            let listHeaderViewModel = TasksListHeaderViewModel()
            let listContainerViewModel = TasksListContainerViewModel(headerViewModel: listHeaderViewModel, listViewModel: listViewModel)
            let mapViewModel = TasksMapViewModel()
            let mapFilterViewModel = TaskMapFilterViewModel()

            // Create split view model
            tasksSplitViewModel = TasksSplitViewModel(listContainerViewModel: listContainerViewModel,
                                                          mapViewModel: mapViewModel,
                                                          filterViewModel: mapFilterViewModel)

            return tasksSplitViewModel.createViewController()

        case .createIncident:
            return CreateIncidentViewModel().createViewController()

        case .mapFilter:
            return tasksSplitViewModel.filterViewModel.createViewController()
        }
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let presentable = presentable as! TaskListScreen

        switch presentable {

        // Present form sheet
        case .mapFilter:
            from.presentFormSheet(to, animated: true)

        // Default presentation, based on container class (eg push if in navigation controller)
        default:
            from.show(to, sender: from)
        }
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is TaskListScreen.Type
    }

}
