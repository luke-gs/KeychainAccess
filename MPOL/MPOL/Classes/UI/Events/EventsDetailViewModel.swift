//
//  EventsDetailViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

public extension EvaluatorKey {
    static let eventReadyToSubmit = EvaluatorKey(rawValue: "eventReadyToSubmit")
}

public class EventsDetailViewModel: EventDetailViewModelType, Evaluatable {

    private static let incidentsHeaderDefaultTitle = "No Incident Selected"
    private static let incidentsHeaderDefaultSubtitle = "IN PROGRESS"

    public var event: Event
    public var title: String?
    public var viewControllers: [UIViewController]?
    public var headerView: UIView?
    public var evaluator: Evaluator = Evaluator()
    public var headerUpdated: (() -> Void)?

    private var readyToSubmit = false {
        didSet {
            evaluator.updateEvaluation(for: .eventReadyToSubmit)
        }
    }

    public required init(event: Event, builder: EventScreenBuilding) {
        self.event = event
        self.title = "New Event"

        self.viewControllers = builder.viewControllers(for: event.reports)
        self.headerView = {
            let header = SidebarHeaderView()

            // Update the header to whatever you need it to be
            let report = event.incidentListReport
            header.titleLabel.text = report?.incidents.first?.title ?? EventsDetailViewModel.incidentsHeaderDefaultTitle
            header.captionLabel.text = EventsDetailViewModel.incidentsHeaderDefaultSubtitle
            header.subtitleLabel.text =  "Saved as Draft"
            header.subtitleLabel.font =  UIFont.systemFont(ofSize: 13)
            return header
        }()

        // Update the header to whatever you need it to be
        updateHeaderImage(with: event.evaluator.isComplete)

        setUpdateHeaderDelegate()

        event.evaluator.addObserver(self)
        evaluator.registerKey(.eventReadyToSubmit) { [weak self] in
            return self?.readyToSubmit ?? false
        }

        readyToSubmit = event.evaluator.isComplete

        if readyToSubmit {
            evaluator.updateEvaluation(for: .eventReadyToSubmit)
        }

    }

    private func setUpdateHeaderDelegate() {
        for case var report as SideBarHeaderUpdateable in event.reports {
            report.delegate = self
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        readyToSubmit = evaluationState
        updateHeaderImage(with: evaluationState)
    }

    private func updateHeaderImage(with isComplete: Bool) {
        guard let header = headerView as? SidebarHeaderView else { return }
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
            header.iconView.image = AssetManager.shared.image(forKey: .edit, ofSize: CGSize(width: 40, height: 40))
            header.iconView.contentMode = .center
        }
        headerUpdated?()
    }
}

extension EventsDetailViewModel: SideBarHeaderUpdateDelegate {
    public func updateHeader(with title: String?, subtitle: String?) {
        guard let header = headerView as? SidebarHeaderView else { return }
        header.titleLabel.text = title ?? EventsDetailViewModel.incidentsHeaderDefaultTitle
        header.captionLabel.text = subtitle ?? EventsDetailViewModel.incidentsHeaderDefaultSubtitle
        headerUpdated?()
    }
}
