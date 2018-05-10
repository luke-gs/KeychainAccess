//
//  EventEntitiesListViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EventEntitiesListViewController : FormBuilderViewController, EvaluationObserverable {

    let viewModel: EventEntitiesListViewModel
    
    public init(viewModel: EventEntitiesListViewModel) {
        self.viewModel = viewModel
        super.init()
        
        self.title = "Entities"
        
        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

        viewModel.evaluator.addObserver(self)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.updateReports()
        self.loadingManager.state = viewModel.loadingManagerState()
        reloadForm()
    }
    
    public override func construct(builder: FormBuilder) {
        builder.title = self.title
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.headerText)

        let reports = viewModel.report.entityDetailReports



        builder += reports.enumerated().map { (itemIndex, report) in
            return viewModel.displayable(for: report.entity)
                .summaryListFormItem()
                .badgeColor(nil)
                .badge(0)
                .detail(viewModel.relationshipStatusFor(itemIndex))
                .detailColorKey(viewModel.invalidRelationshipsColor())
                .onSelection { cell in
                    guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                    self.showDetailsFor(self.viewModel.reportFor(indexPath))
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //text and image for "noContent" state
        loadingManager.noContentView.titleLabel.text = "No Entities Added"
        loadingManager.noContentView.subtitleLabel.text = "Entities added to an incident will appear here"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
        
    }

    private func showDetailsFor(_ report: EventEntityDetailReport) {
        let viewModel = EventEntityDetailViewModel(report: report, event: self.viewModel.report.event!)
        let viewController = EventEntityDetailsSplitViewController(viewModel: viewModel)
        self.parent?.navigationController?.pushViewController(viewController, animated: true)
    }

    //MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
}
