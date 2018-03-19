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

    // TEMP INVOLVEMENTS
    fileprivate let involvements = [
        "Reporting Officer", 
        "Assisting Officer",
        "Case Officer",
        "Forensic Intelligence Officer",
        "Interviewing Officer",
        "Accident Officer",
        "Action Officer",
    ]

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
        sidebarItem.color = viewModel.report.evaluator.isComplete ? .green : .red
        sidebarItem.count = UInt(viewModel.officerDisplayables.count)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(sender:)))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc private func addTapped(sender: UIBarButtonItem) {

        let officer = Officer()
        officer.givenName = "Pavel"
        officer.rank = "Sergeant"
        officer.region = "Melbourne"
        officer.employeeNumber = "BJ3466"
        officer.surname = "Boryseiko"
        officer.involvements = ["Reporting Officer"]

        let viewModel = OfficerSearchViewModel(items: [officer])
        let officerSearchController = SearchDisplayableViewController<DefaultEventOfficerListViewController, OfficerSearchViewModel>(viewModel: viewModel)
        officerSearchController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        officerSearchController.delegate = self

        let navController = UINavigationController(rootViewController: officerSearchController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report.viewed = true
    }
    
    open override func construct(builder: FormBuilder) {
       viewModel.construct(builder: builder)
    }

    // MARK: - Officer model delegate 

    public func didSelectOfficer(officer: Officer) {
        guard let displayable = viewModel.displayable(for: officer) else { return }
        let headerConfig = SearchHeaderConfiguration(title: displayable.title,
                                                     subtitle: displayable.detail1 ?? "No involvements selected",
                                                     image: displayable.thumbnail(ofSize: .small),
                                                     imageStyle: .circle)
        let datasource = OfficerInvolvementSearchDatasource(objects: involvements,
                                                            selectedObjects: officer.involvements,
                                                            configuration: headerConfig)
        datasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))
        let viewController = CustomPickerController(datasource: datasource)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        viewController.finishUpdateHandler = { controller, index in
            let newInvolvements = controller.objects.enumerated().filter { index.contains($0.offset) }.flatMap { $0.element.title }
            self.viewModel.report.officers.first(where: { $0.employeeNumber == officer.employeeNumber })?.involvements = newInvolvements
            self.reloadForm()
        }

        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }

    public func officerListDidUpdate() {
        reloadForm()
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }

    // MARK: - Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }

}

extension DefaultEventOfficerListViewController: SearchDisplayableDelegate {

    public typealias Object = Officer

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Officer) {

        let displayable = OfficerSummaryDisplayable(object)
        let headerConfig = SearchHeaderConfiguration(title: displayable.title,
                                                     subtitle: displayable.detail1 ?? "No involvements selected",
                                                     image: displayable.thumbnail(ofSize: .small)?.sizing().image)

        let involvementDatasource = OfficerInvolvementSearchDatasource(
            objects: involvements,
            selectedObjects: object.involvements,
            configuration: headerConfig)
        involvementDatasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

        let involvementsViewController = CustomPickerController(datasource: involvementDatasource)
        involvementsViewController.finishUpdateHandler = { controller, index in
            object.involvements = controller.objects.enumerated().filter { index.contains($0.offset) }.flatMap { $0.element.title }
            self.viewModel.add(officer: object)
            self.reloadForm()
        }
        viewController.navigationController?.pushViewController(involvementsViewController, animated: true)
    }

}
