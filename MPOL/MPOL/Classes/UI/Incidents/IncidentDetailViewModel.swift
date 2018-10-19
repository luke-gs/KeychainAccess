//
//  IncidentDetailViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

public class IncidentDetailViewModel: IncidentDetailViewModelType, Evaluatable {

    public var incident: Incident
    public var title: String?
    public var viewControllers: [UIViewController]?
    public var headerView: UIView?
    public var evaluator: Evaluator = Evaluator()
    public var headerUpdated: (() -> Void)?

    public required init(incident: Incident, builder: IncidentScreenBuilding) {
        self.incident = incident
        self.title = "New Incident"
        self.headerView = SidebarHeaderView()
        updateHeaderImage(with: self.incident.evaluator.isComplete)
        self.viewControllers = builder.viewControllers(for: incident.reports)

        incident.evaluator.addObserver(self)
    }

    private func updateHeaderImage(with isComplete: Bool) {

        guard let header = headerView as? SidebarHeaderView else { return }

        header.titleLabel.text = incident.incidentType.rawValue
        header.subtitleLabel.text =  "Saved as Draft"
        header.subtitleLabel.font =  UIFont.systemFont(ofSize: 13)
        if isComplete {
            header.captionLabel.text = "COMPLETED"
            header.captionLabel.textColor = UIColor.midGreen
            header.iconView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconHeaderFinalise)
            header.iconView.contentMode = .center
            header.iconView.backgroundColor = UIColor.midGreen
            header.iconView.tintColor = UIColor.sidebarBlack
        } else {
            header.captionLabel.text = "IN PROGRESS"
            header.captionLabel.textColor =  UIColor.secondaryGray
            header.iconView.backgroundColor = UIColor.sidebarGray
            header.iconView.tintColor = UIColor.secondaryGray
            header.iconView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconHeaderEdit)
            header.iconView.contentMode = .center
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        updateHeaderImage(with: evaluationState)
        headerUpdated?()
    }

}
