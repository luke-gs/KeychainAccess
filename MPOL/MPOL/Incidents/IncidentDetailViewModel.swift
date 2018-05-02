//
//  IncidentDetailViewModel.swift
//  MPOL
//
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
    public var headerUpdated: (() -> ())?

    public required init(incident: Incident, builder: IncidentScreenBuilding) {
        self.incident = incident
        self.title = "New Incident"
        self.headerView = SidebarHeaderView()
        updateHeader(incidentComplete: self.incident.evaluator.isComplete)
        self.viewControllers = builder.viewControllers(for: incident.reports)

        incident.evaluator.addObserver(self)
    }

    private func updateHeader(incidentComplete: Bool) {

        guard let header = headerView as? SidebarHeaderView else { return }
        
        header.titleLabel.text = incident.incidentType.rawValue
        if incidentComplete {
            header.captionLabel.text = "COMPLETED"
            header.captionLabel.textColor = UIColor.brightGreen
            header.iconView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.finalise)
            header.iconView.contentMode = .center
            header.iconView.backgroundColor = UIColor.brightGreen
            header.iconView.tintColor = UIColor.sidebarBlack
        } else {
            header.captionLabel.text = "IN PROGRESS"
            header.captionLabel.textColor =  UIColor.secondaryGray
            header.iconView.backgroundColor = UIColor.sidebarGray
            header.iconView.tintColor = UIColor.secondaryGray
            header.iconView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconPencil)
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        updateHeader(incidentComplete: evaluationState)
        headerUpdated?()
    }

}

