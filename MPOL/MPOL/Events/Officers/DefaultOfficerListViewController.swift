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
        sidebarItem.count = UInt(viewModel.officerDisplayables.count)
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(sender:)))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc private func addTapped(sender: UIBarButtonItem) {

        let viewModel = OfficerSearchViewModel()
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
        builder += HeaderFormItem(text: viewModel.header)
        let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconPencil)

        viewModel.officerDisplayables.forEach { displayable in
            builder += SummaryListFormItem()
                .title(displayable.title)
                .subtitle(displayable.detail1)
                .width(.column(1))
                .image(displayable.thumbnail(ofSize: .small))
                .selectionStyle(.none)
                .imageStyle(.circle)
                .accessory(CustomItemAccessory(onCreate: { () -> UIView in
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFit
                    return imageView
                }, size: image?.size ?? .zero))
                .onSelection({ (cell) in
                    let officer = displayable.officer
                    self.viewModel.delegate?.didSelectOfficer(officer: officer)
                })
                .editActions(viewModel.officerDisplayables.count == 1 ? [] : [CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in
                    self.viewModel.removeOfficer(at: indexPath)
                    self.viewModel.delegate?.officerListDidUpdate()
                })])
        }
    }

    // MARK: - Officer model delegate 

    public func didSelectOfficer(officer: Officer) {
        guard let displayable = viewModel.displayable(for: officer) else { return }
        let headerConfig = SearchHeaderConfiguration(title: displayable.title,
                                                     subtitle: displayable.detail1 ?? "No involvements selected",
                                                     image: displayable.thumbnail(ofSize: .small),
                                                     imageStyle: .circle)
        let datasource = DefaultPickableSearchDatasource(objects: involvements,
                                                            selectedObjects: officer.involvements,
                                                            title: "Involvements",
                                                            configuration: headerConfig)
        datasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))
        let viewController = CustomPickerController(datasource: datasource)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        viewController.finishUpdateHandler = { controller, index in
            let involvements = controller.objects.enumerated().filter { index.contains($0.offset) }.compactMap { $0.element.title }
            self.viewModel.add(involvements, to: officer)
            self.reloadForm()
        }

        let navController = PopoverNavigationController(rootViewController: viewController)
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
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

}

extension DefaultEventOfficerListViewController: SearchDisplayableDelegate {
    public typealias Object = Officer

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Officer) {

        let displayable = viewModel.displayable(for: object) ?? OfficerSummaryDisplayable(object)
        let officer = displayable.officer
        let headerConfig = SearchHeaderConfiguration(title: displayable.title,
                                                     subtitle: displayable.detail1 ?? "No involvements selected",
                                                     image: displayable.thumbnail(ofSize: .small)?.sizing().image)

        let involvementDatasource = DefaultPickableSearchDatasource(
            objects: involvements,
            selectedObjects: officer.involvements,
            title: "Involvements",
            configuration: headerConfig)
        involvementDatasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

        let involvementsViewController = CustomPickerController(datasource: involvementDatasource)
        involvementsViewController.finishUpdateHandler = { controller, index in
            let involvements = controller.objects.enumerated().filter { index.contains($0.offset) }.compactMap { $0.element.title }
            self.viewModel.add(officer: officer)
            self.viewModel.add(involvements, to: officer)
            self.reloadForm()
        }
        viewController.navigationController?.pushViewController(involvementsViewController, animated: true)
    }

}
