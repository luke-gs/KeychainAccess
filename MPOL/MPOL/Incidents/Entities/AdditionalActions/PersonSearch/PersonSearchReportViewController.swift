//
//  PersonSearchReportViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

public class PersonSearchReportViewController: FormBuilderViewController, EvaluationObserverable {

    public let viewModel: PersonSearchReportViewModel

    public init(viewModel: PersonSearchReportViewModel) {
        self.viewModel = viewModel
        super.init()
        self.title = "Person Search Report"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(doneSelected))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneSelected))
        viewModel.report.evaluator.addObserver(self)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    @objc func doneSelected(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override open func construct(builder: FormBuilder) {
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        builder.title = sidebarItem.regularTitle

        builder += LargeTextHeaderFormItem(text: "Searched Overview")
            .separatorColor(.clear)

        // searchType pickerFormItems
        let searchTypeOptions = ["Frisk", "Pat-down", "Production Notice Warrant", "Unclothed"]

        builder += DropDownFormItem(title: "SearchType")
            .width(.column(1))
            .placeholder("Optional")
            .options(searchTypeOptions)
            .selectedValue([viewModel.report.searchType ?? ""])
            .onValueChanged({ values in
                self.viewModel.report.searchType = values?.first
            })

        // DatePicker formItems
        builder += DateFormItem(title: "Detained Started At")
            .required()
            .width(.column(2))
            .selectedValue(viewModel.report.detainedStart)
            .withNowButton(true)
            .onValueChanged({ (date) in
                self.viewModel.report.detainedStart = date
            })

        builder += DateFormItem(title: "Detained Ended At")
            .width(.column(2))
            .selectedValue(viewModel.report.detainedEnd)
            .withNowButton(true)
            .placeholder("Optional")
            .onValueChanged({ (date) in
                self.viewModel.report.detainedEnd = date
            })

        builder += DateFormItem(title: "Search Started At")
            .required()
            .width(.column(2))
            .selectedValue(viewModel.report.searchStart)
            .withNowButton(true)
            .onValueChanged({ (date) in
                self.viewModel.report.searchStart = date
            })

        builder += DateFormItem(title: "Search Ended At")
            .width(.column(2))
            .selectedValue(viewModel.report.searchEnd)
            .withNowButton(true)
            .placeholder("Optional")
            .onValueChanged({ (date) in
                self.viewModel.report.searchEnd = date
            })

        // locationPickerformitem
        let locationViewModel = LocationSelectionViewModel(location: self.viewModel.report.location)

        builder += PickerFormItem(pickerAction: LocationAction(viewModel: locationViewModel))
            .required()
            .width(.column(1))
            .title("Location")
            .selectedValue(viewModel.report.location)
            .onValueChanged({ (location) in
                self.viewModel.report.location = location
            })


        builder += LargeTextHeaderFormItem(text: "Searching Officers")
            .sectionIsRequired(true)
            .separatorColor(.clear)
            .actionButton(title: "Add") { button in
                self.addTapped()
            }

        // offcier list
        viewModel.report.officerDisplayables.enumerated().forEach { (index, displayable) in

            builder += SummaryListFormItem()
                .title(displayable.title)
                .width(.column(1))
                .image(displayable.thumbnail(ofSize: .small))
                .selectionStyle(.none)
                .imageStyle(.circle)
                .editActions([CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { cell, indexPath in
                    self.viewModel.report.officerDisplayables.remove(at: index)
                    self.reloadForm()
                })])
        }

        builder += LargeTextHeaderFormItem(text: "Searched Details")
            .separatorColor(.clear)

        // legalPower pickerFormItem
        let legalOptions = ["COA 2009", "CPA - Child Immediate Risk", "Other - See Remarks", "PGBA",
                            "PPRA - 21B(1)(a) CPOR compliance", "PPRA - 21B(1)(b) CPOR compliance",
                            "PPRA - 21B(1)(c) CPOR compliance", "PPRA - Crime Scene",
                            "PPRA - Emergent", "PPRA - In Custody", "PPRA - Potentially Harmful Things",
                            "PPRA - Prevent Offence/Injury/DV", "PPRA - Production Notice",
                            "PPRA - Search Warrant", "PPRA - Without Warrant", "PSPA - Powers", "RTRA Act"]

        builder += DropDownFormItem(title: "Legal Power")
            .required()
            .width(.column(4))
            .options(legalOptions)
            .selectedValue([viewModel.report.legalPower ?? ""])
            .onValueChanged({ values in
                self.viewModel.report.legalPower = values?.first
            })

        // searchReasons pickerFormItem
        let reasonsOptions = ["Articles - Harm", "Bladed Weapon", "Criminal Organisation", "Device Inspection", "Drugs",
                              "Evidence", "Explosives", "Firearms", "Implement", "Other - See Remarks", "Property",
                              "Volatile Substance Misuse", "Weapon - Other"]

        builder += DropDownFormItem(title: "Reasons for Search")
            .required()
            .width(.column(4))
            .options(reasonsOptions)
            .selectedValue([viewModel.report.searchReason ?? ""])
            .onValueChanged({ values in
                self.viewModel.report.searchReason = values?.first
            })

        // outcome pickerFormItem
        let outcomeOptions = ["Damage Incurred", "Evidence Located", "Nil Located", "Person Located",
                              "Personal Items Located", "Proceedings Commenced", "Property Seized"]

        builder += DropDownFormItem(title: "Outcome")
            .required()
            .width(.column(4))
            .options(outcomeOptions)
            .selectedValue([viewModel.report.outcome ?? ""])
            .onValueChanged({ values in
                self.viewModel.report.outcome = values?.first
            })

        builder += OptionGroupFormItem(optionStyle: .radio, options: ["Yes", "No"])
            .title("Was any outer clothing removed or moved during the search?")
            .required()
            .width(.column(1))
            .selectedIndexes(viewModel.clothingRemoved)
            .onValueChanged({ (indexes) in
                self.viewModel.setClothingRemoved(indexSet: indexes)
            })

        // remarks formItem
        builder += TextFieldFormItem(title: "Remarks", text: nil, placeholder: "Optional")
            .width(.column(1))
            .text(viewModel.report.remarks)
            .onValueChanged({ (value) in
                self.viewModel.report.remarks = value
            })
    }

    private func addTapped() {

        let viewModel = OfficerSearchViewModel()
        let officerSearchController = SearchDisplayableViewController<PersonSearchReportViewController, OfficerSearchViewModel>(viewModel: viewModel)
        officerSearchController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismiss))
        officerSearchController.delegate = self

        let navController = UINavigationController(rootViewController: officerSearchController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)

    }

    @objc private func dismiss(sender: UIButton) {
        dismissAnimated()
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }
}

extension PersonSearchReportViewController: SearchDisplayableDelegate {
    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Officer) {
        self.viewModel.report.officerDisplayables.append(OfficerSummaryDisplayable(object))
        reloadForm()
        viewController.dismiss(animated: true, completion: nil)
    }
}
