//
//  CreateTaskPresenter.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import DemoAppKit
import PublicSafetyKit
import PromiseKit

public class CreateTaskPresenter: Presenter {
    
    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let presentable = presentable as! CreateTaskScreen
        
        switch presentable {
        case .createTaskMain:
        
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
            
        case .createTaskAddEntity(let completionHandler):
            let viewModel = RecentEntitySummarySelectionViewModel()
            viewModel.allowedEntityTypes = [Person.self, Vehicle.self]
            
            let viewController = EntitySummarySelectionViewController(viewModel: viewModel)
            viewController.selectionHandler = { entity in
                // Close UI and call completion handler
                viewController.navigationController?.popViewController(animated: true)
                completionHandler?(entity)
            }
            return viewController
            
            
        case .createTaskSearchEntity:
            //TODO: Will redirect to search, return dummy VC here
            return UIViewController()
        
        }
        
    }
    
    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        
        let presentable = presentable as! CreateTaskScreen
        
        switch presentable {
        case .createTaskMain, .createTaskAddEntity(_):
            from.navigationController?.pushViewController(to, animated: true)
        case .createTaskSearchEntity:
            from.dismiss(animated: true) {
                let activity = SearchActivity.searchEntity(term: Searchable(text: "", type: "Vehicle"))
                do {
                    try SearchActivityLauncher.default.launch(activity, using: AppURLNavigator.default)
                }  catch {
                    AlertQueue.shared.addSimpleAlert(title: "An Error Has Occurred", message: "Failed To Launch Entity Search")
                }
            }
        }
    }
    
    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presentableType is  CreateTaskScreen.Type
    }
    
}
