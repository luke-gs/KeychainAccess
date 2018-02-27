//
//  IncidentDetailViewModel.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

public class IncidentDetailViewModel: IncidentDetailViewModelType, Evaluatable {

    public var incident: Incident
    public var title: String?
    public var viewControllers: [UIViewController]?
    public var headerView: UIView?
    public var evaluator: Evaluator = Evaluator()

    private var readyToSubmit = false {
        didSet {
            evaluator.updateEvaluation(for: .eventReadyToSubmit)
        }
    }

    public required init(incident: Incident, builder: IncidentScreenBuilding) {
        self.incident = incident
        self.title = "New Incident"

        self.viewControllers = builder.viewControllers(for: incident.reports)
        self.headerView = {
            let header = SidebarHeaderView()
            header.iconView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconPencil)
            header.titleLabel.text = incident.incidentType.rawValue
            header.captionLabel.text = "IN PROGRESS"
            return header
        }()

        evaluator.registerKey(.eventReadyToSubmit) {
            return self.readyToSubmit
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }

}

