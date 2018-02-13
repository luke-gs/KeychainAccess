//
//  DefaultOfficerListViewController.swift
//  MPOL
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

extension EvaluatorKey {
    static let officers = EvaluatorKey(rawValue: "officerList")
}

open class DefaultEventOfficerListViewController: FormBuilderViewController, EvaluationObserverable, EventOfficerListViewModelDelegate {

    let viewModel: EventOfficerListViewModel

    public init(viewModel: EventOfficerListViewModel) {

        self.viewModel = viewModel

        super.init()

        viewModel.report.evaluator.addObserver(self)
        viewModel.delegate = self

        let title = viewModel.title

        self.title = title
        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: .resourceGeneral)
        sidebarItem.color = .red
        sidebarItem.count = UInt(viewModel.officerDisplayables.count)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(sender:)))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc private func addTapped(sender: UIBarButtonItem) {

        let officer = Officer()
        officer.givenName = "Aimee"
        officer.surname = "Esselmont"
        officer.involvements = ["Reporting Officer"]

        let displayable = OfficerSummaryDisplayable(officer)

        let involvements = [
            "Reporting Officer",
            "Assisting Officer",
            "Case Officer",
            "Forensic Intelligence Officer",
            "Interviewing Officer",
            "Accident Officer",
            "Action Officer",
        ]

        let headerConfig = SearchHeaderConfiguration(title: displayable.title, subtitle: displayable.detail1?.ifNotEmpty() ?? "No involvements selected", image: displayable.thumbnail(ofSize: .small)?.sizing().image)
        let datasource = OfficerInvolvementSearchDatasource(objects: involvements,
                                                 selectedObjects: officer.involvements,
                                                 title: "Involvements",
                                                 allowsMultipleSelection: true,
                                                 configuration: headerConfig)
        datasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

        let viewController = CustomPickerController(datasource: datasource)
        let navController = PopoverNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report.viewed = true
    }

    @objc private func searchHeaderTapped() {
        print("search")
    }

    open override func construct(builder: FormBuilder) {
       viewModel.construct(builder: builder)
    }

    public func officerListDidUpdate() {
        reloadForm()
    }

    // MARK: - Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .green : .red
    }

}
