//
//  ClusterTasksViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import Cluster
import PublicSafetyKit
open class ClusterTasksViewModel: CADFormCollectionViewModel<TasksListItemViewModel> {

    public init(annotationView: MPOLClusterAnnotationView) {
        super.init()

        // Convert all the annotations to TasksListItemViewModels
        if let clusterAnnotation = annotationView.annotation as? ClusterAnnotation {
            convertAnnotationsToViewModels(annotations: clusterAnnotation.annotations)
        }
    }

    /// Convert the annotations to view models. Override for client specific implementation
    open func convertAnnotationsToViewModels(annotations: [MKAnnotation]) {
        MPLRequiresConcreteImplementation()
    }

    /// Create the view controller for this view model
    open func createViewController(delegate: ClusterTasksViewControllerDelegate?) -> UIViewController {
        let viewController = ClusterTasksViewController(viewModel: self)
        viewController.delegate = delegate
        return viewController
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Cluster Details", comment: "")
    }
}
