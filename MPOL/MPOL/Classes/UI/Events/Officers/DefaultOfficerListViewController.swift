//
//  DefaultOfficerListViewController.swift
//  MPOL
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

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
        let officerSearchController = OfficerSearchViewController<DefaultEventOfficerListViewController>(viewModel: viewModel)
        officerSearchController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        officerSearchController.delegate = self

        let navController = ModalNavigationController(rootViewController: officerSearchController)
        navController.modalPresentationStyle = .formSheet
        navController.preferredContentSize = CGSize(width: 512, height: 736)
        pushableSplitViewController?.presentModalViewController(navController, animated: true, completion: nil)

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report.viewed = true
    }

    open override func construct(builder: FormBuilder) {
        builder += LargeTextHeaderFormItem(text: viewModel.header)
            .separatorColor(.clear)

        viewModel.officerDisplayables.forEach { displayable in
            let summaryListFormItem = SummaryListFormItem()
                .title(displayable.title)
                .subtitle(displayable.detail1)
                .detail(displayable.detail2)
                .styleIdentifier(DemoAppKitStyler.associationStyle)
                .width(.column(1))
                .image(displayable.thumbnail(ofSize: .small))
                .selectionStyle(.none)
                .imageStyle(.circle)
                .accessory(ItemAccessory.pencil)
                .onSelection { [weak self] (_) in
                    guard let `self` = self else { return }
                    let officer = displayable.officer
                    self.viewModel.delegate?.didSelectOfficer(officer: officer)
            }

            // Only add deletion action if the officer is not the user and there is more than one officer.
            guard viewModel.officerDisplayables.count > 1
                && displayable.officer != UserSession.current.userStorage?.retrieve(key: UserSession.currentOfficerKey) else {
                builder += summaryListFormItem
                return
            }

            builder += summaryListFormItem.editActions([
                CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { [weak self] (_, indexPath) in
                    guard let `self` = self else { return }
                    let officer = self.viewModel.officer(at: indexPath)
                    if officer.involvements.contains(EventOfficerListViewModel.reportingOfficerInvolvement) {
                        self.presentReportingOfficerAlert(for: officer, from: self, completion: { success in
                            guard success == true else { return }
                            let fallBackOfficer = self.viewModel.officer(at: IndexPath(row: 0, section: 0))
                            fallBackOfficer.involvements.append(EventOfficerListViewModel.reportingOfficerInvolvement)
                        })
                    } else {
                        self.viewModel.remove(officer)
                        self.updateSidebarItemCount()
                    }
                })]
            )
        }
    }

    /// Presents an alert that describes that at least one reporting officer is required.
    /// If the officer is supplied then it will attempt to remove it from the viewModels officer list.
    ///
    /// - Parameters:
    ///   - officer: The officer that the requirement has been changed upon. Defaults to nil
    ///   - controller: The controller from which to present the alert from. Can be presented
    ///                 from the picker controller as well.
    private func presentReportingOfficerAlert(for officer: Officer? = nil,
                                              from controller: UIViewController,
                                              completion: ((Bool) -> Void)? = nil) {
        let fallBackOfficer = self.viewModel.officer(at: IndexPath(row: 0, section: 0))
        let fallBackOfficerName = [fallBackOfficer.familyName, fallBackOfficer.givenName].joined(separator: ", ")

        let alertController = PSCAlertController(
            title: NSLocalizedString("Before You Continue", comment: ""),
            message: NSLocalizedString("This officer is currently assigned as the Reporting Officer. This involvement is required and will be reassigned to \(fallBackOfficerName)", comment: ""))
        let cancelAction = PSCAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel,
            handler: { action in
                completion?(false)
            }
        )

        let continueAction = PSCAlertAction(
            title: NSLocalizedString("Continue", comment: ""),
            style: .default,
            handler: { [weak self] action in
                guard let self = self else { return }
                completion?(true)
                if let officer = officer {
                    self.viewModel.remove(officer)
                    self.updateSidebarItemCount()
                }
                self.reloadForm()
                controller.dismiss(animated: true, completion: nil)
        })
        alertController.addActions([cancelAction, continueAction])
        AlertQueue.shared.add(alertController)
    }

    // MARK: - Officer model delegate 

    public func didSelectOfficer(officer: Officer) {
        guard let displayable = viewModel.displayable(for: officer) else { return }
        let headerConfig = SearchHeaderConfiguration(title: displayable.title?.sizing().string,
                                                     subtitle: displayable.detail1?.sizing().string ?? "No involvements selected",
                                                     image: displayable.thumbnail(ofSize: .small),
                                                     imageStyle: .circle)

        // If the report contains only a single officer then when modifying his involvements
        // the user cannot deselect the value of reporting officer.
        let officerSelectionHandler: (Pickable) -> Bool = { [unowned self] object in
            guard self.viewModel.report.officers.count == 1 else { return true }
            return !(object.title?.string.caseInsensitiveCompare(EventOfficerListViewModel.reportingOfficerInvolvement) == .orderedSame)
        }

        let dataSource = DefaultPickableSearchDataSource(objects: viewModel.officerInvolvementOptions,
                                                         selectedObjects: officer.involvements,
                                                         title: "Involvements",
                                                         dismissOnFinish: false,
                                                         configuration: headerConfig,
                                                         selectionSatisfyHandler: officerSelectionHandler)
        dataSource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))
        let viewController = CustomPickerController(dataSource: dataSource)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        // Rather than modify the Kit for the weird logic regarding reporting officer
        // The done button of the picker controller is modified here
        viewController.navigationItem.rightBarButtonItem?.title = "Done"

        viewController.finishUpdateHandler = { [weak self] controller, index in
            guard let self = self else { return }
            let involvements = controller.objects.enumerated().filter { index.contains($0.offset) }.compactMap { $0.element.title?.sizing().string }
            guard self.viewModel.containsReportingOfficer() else {
                self.presentReportingOfficerAlert(from: controller, completion: { [weak self] success in
                    guard let self = self, success == true else { return }
                    self.viewModel.add(involvements, to: officer)
                })
                return
            }
            self.viewModel.add(involvements, to: officer)
            controller.dismiss(animated: true, completion: nil)
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

    private func updateSidebarItemCount() {
        self.sidebarItem.count = UInt(self.viewModel.officerDisplayables.count)
    }

}

extension DefaultEventOfficerListViewController: SearchDisplayableDelegate {
    public typealias Object = Officer

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Officer) {

        let displayable = viewModel.displayable(for: object) ?? OfficerSummaryDisplayable(object)
        let officer = displayable.officer
        let headerConfig = SearchHeaderConfiguration(title: displayable.title?.sizing().string,
                                                     subtitle: displayable.detail1?.sizing().string ?? "No involvements selected",
                                                     image: displayable.thumbnail(ofSize: .small)?.sizing().image)

        let involvementDataSource = DefaultPickableSearchDataSource(
            objects: viewModel.officerInvolvementOptions,
            selectedObjects: officer.involvements,
            title: "Involvements",
            configuration: headerConfig)
        involvementDataSource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

        let involvementsViewController = CustomPickerController(dataSource: involvementDataSource)
        involvementsViewController.finishUpdateHandler = { [weak self] controller, index in
            guard let `self` = self else { return }
            let involvements = controller.objects.enumerated().filter { index.contains($0.offset) }.compactMap { $0.element.title?.sizing().string }
            self.viewModel.add(officer: officer)
            self.viewModel.add(involvements, to: officer)
            self.updateSidebarItemCount()
            self.reloadForm()
        }
        viewController.navigationController?.pushViewController(involvementsViewController, animated: true)
    }

}
