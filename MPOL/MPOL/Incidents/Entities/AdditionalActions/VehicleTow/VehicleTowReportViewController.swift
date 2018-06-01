//
//  VehicleTowReportViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

open class VehicleTowReportViewController: FormBuilderViewController, EvaluationObserverable {

    public let viewModel: VehicleTowReportViewModel

    public init(viewModel: VehicleTowReportViewModel) {
        self.viewModel = viewModel
        super.init()
        self.title = "Vehicle Tow Report"
        wantsTransparentBackground = false
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

        builder += LargeTextHeaderFormItem(text: "General")
            .separatorColor(.clear)

        // locationPickerformitem
        let locationViewModel = LocationSelectionViewModel(location: self.viewModel.report.location)

        builder += PickerFormItem(pickerAction: LocationAction(viewModel: locationViewModel))
            .required()
            .width(.column(1))
            .title("Where was the Vehicle Towed from?")
            .selectedValue(viewModel.report.location)
            .onValueChanged({ (location) in
                self.viewModel.report.location = location
            })

        // dropDownFormItem
        let options = ["Criminal Organisation", "Traffic Investigation", "Other", "Seized",
                       "Traffic Hazard", "Traffic Complaint", "Type 1 Vehicle Related",
                       "Type 2 Vehicle Related", "Scientific Examination"]

        builder += DropDownFormItem(title: "Reason for the Tow")
            .width(.column(2))
            .placeholder("Optional")
            .options(options)
            .selectedValue([viewModel.report.towReason ?? ""])
            .onValueChanged({ values in
                self.viewModel.report.towReason = values?.first
            })

        // officerPickerFormItems
        builder += PickerFormItem(pickerAction: OfficerSelectionAction(viewModel: OfficerSearchViewModel()))
            .width(.column(2))
            .title("Officer Authorising Tow")
            .placeholder("Optional")
            .selectedValue(viewModel.report.authorisingOfficer)
            .onValueChanged({ [viewModel] officer in
                viewModel.report.authorisingOfficer = officer
            })

        builder += PickerFormItem(pickerAction: OfficerSelectionAction(viewModel: OfficerSearchViewModel()))
            .width(.column(2))
            .title("Who Notified Driver of Tow")
            .placeholder("Optional")
            .selectedValue(viewModel.report.notifyingOfficer)
            .onValueChanged({ [viewModel] officer in
                viewModel.report.notifyingOfficer = officer
            })

        // datePickerFormItem
        builder += DateFormItem(title: "Date Notified")
            .width(.column(2))
            .selectedValue(viewModel.report.date)
            .placeholder("Optional")
            .onValueChanged({ (date) in
                self.viewModel.report.date = date
            })


        builder += LargeTextHeaderFormItem(text: "Vehicle Hold")
            .separatorColor(.clear)

        // radioButtonFormItem
        builder += OptionGroupFormItem(optionStyle: .radio, options: ["Yes", "No"])
            .title("Is there a Hold on this Vehicle?")
            .required()
            .width(.column(1))
            .selectedIndexes((viewModel.vehicleHold))
            .onValueChanged({ (indexes) in
                self.viewModel.setVehicleHold(indexSet: indexes)
            })

        // textFieldFormItems
        builder += TextFieldFormItem(title: "Reason for Hold", text: nil, placeholder: "Optional")
            .width(.column(1))
            .text(viewModel.report.holdReason)
            .onValueChanged({ (value) in
                self.viewModel.report.holdReason = value
            })

        builder += TextFieldFormItem(title: "Remarks", text: nil, placeholder: "Optional")
            .width(.column(1))
            .text(viewModel.report.holdRemarks)
            .onValueChanged({ (value) in
                self.viewModel.report.holdRemarks = value
            })

        // Media Setup
        let localStore = DataStoreCoordinator(dataStore: MediaStorageDatastore(items: viewModel.report.media, container: viewModel.report))
        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: localStore)
        let mediaItem = MediaFormItem()
        mediaItem.previewingController(self)

        builder += LargeTextHeaderFormItem(text: "Media")
            .separatorColor(.clear)
            .actionButton(title: "Manage") { button in
                if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                    self.present(viewController, animated: true, completion: nil)
                }
        }

        builder += mediaItem
            .dataSource(gallery)
            .emptyStateContents(EmptyStateContents(
                title: "No Media",
                subtitle: "Add media by tapping on the 'Manage' button."))
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }
}
