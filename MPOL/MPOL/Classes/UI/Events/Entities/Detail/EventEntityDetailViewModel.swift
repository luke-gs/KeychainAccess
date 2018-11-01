//
//  EventEntityDetailViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey("allValid")
}

open class EventEntityDetailViewModel {
    public unowned var event: Event
    public unowned var report: EventEntityDetailReport

    init(report: EventEntityDetailReport, event: Event) {
        self.event = event
        self.report = report
    }

    func viewControllers() -> [UIViewController] {
        return [
            EventEntityDescriptionViewController(viewModel: EventEntityDescriptionViewModel(report: report.descriptionReport)),
            EventEntityRelationshipsViewController(viewModel: EventEntityRelationshipsViewModel(report: report.relationshipsReport))
        ]
    }

    func headerView() -> UIView {
        let headerView = SidebarHeaderView()
        guard let entity = report.entity else { return headerView }

        let detailDisplayable = EntityDetailsDisplayable(entity)
        headerView.captionLabel.text = detailDisplayable.entityDisplayName?.localizedUppercase

        let summaryDisplayable = EntitySummaryDisplayFormatter.default.summaryDisplayForEntity(entity)
        headerView.titleLabel.text = summaryDisplayable?.title

        headerView.subtitleLabel.text = "Saved as Draft"
        headerView.subtitleLabel.font = UIFont.systemFont(ofSize: 13)

        if let thumbnailInfo = summaryDisplayable?.thumbnail(ofSize: .small) {
            headerView.iconView.setImage(with: thumbnailInfo)
        }

        return headerView
    }
}
