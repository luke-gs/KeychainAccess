//
//  VehicleEditViewController.swift
//  MPOL
//
//  Created by KGWH78 on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class VehicleEditViewController: FormBuilderViewController {

    private let numberFormatter = NumberFormatter()

    // MARK: Group validation form items
    var headerItem: HeaderFormItem?
    var item1: TextFieldFormItem?
    var item2: TextFieldFormItem?
    var item3: TextFieldFormItem?
    // MARK: - Storage

    private var finalVehicle = Vehicle(id: UUID().uuidString)

    public init(initialVehicle: Vehicle? = nil) {
        if let initialVehicle = initialVehicle {
            self.finalVehicle = initialVehicle
        }
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitButtonTapped(_:)))
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func construct(builder: FormBuilder) {
        builder.title = NSLocalizedString("Create New Vehicle", comment: "Title")

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("General", comment: "General Section Header")).separatorColor(.clear)

        builder += DropDownFormItem()
            .title(NSLocalizedString("Vehicle Type", comment: "Drop Down Title"))
            .options(["Car", "Motorcycle", "Van", "Truck", "Trailer", "Vessel"])
            .onValueChanged { self.finalVehicle.vehicleType = $0?.first }
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Select", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .width(.column(4))
            .onStyled { cell in
                guard let cell = cell as? CollectionViewFormValueFieldCell else { return }
                cell.placeholderLabel.textColor = cell.valueLabel.textColor
            }

        builder += DropDownFormItem()
            .title(NSLocalizedString("State", comment: "Drop Down Title"))
            .options(["VIC", "NSW", "QLD", "ACT", "NT", "WA", "TAS"])
            .onValueChanged { self.finalVehicle.registrationState = $0?.first }
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Select", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .width(.column(4))
            .onStyled { cell in
                guard let cell = cell as? CollectionViewFormValueFieldCell else { return }
                cell.placeholderLabel.textColor = cell.valueLabel.textColor
            }

        builder += ValueFormItem()
            .width(.column(2))
            .separatorStyle(.none)

        headerItem = HeaderFormItem()
            .text("AT LEAST ONE OF THE FIELDS BELOW ARE REQUIRED")
        builder += headerItem!

        item1 = TextFieldFormItem()
            .title(NSLocalizedString("Registration Number", comment: "Vehicle Number"))
            .placeholder(StringSizing(string: ""))
            .onValueChanged {
                self.finalVehicle.registration = $0

                self.updateGroupValidationFormItems()
            }
            .width(.column(4))

        builder += item1!

        item2 = TextFieldFormItem()
            .title(NSLocalizedString("VIN/Chassis Number", comment: "Title"))
            .placeholder(StringSizing(string: ""))
            .onValueChanged {
                self.finalVehicle.vin = $0
                self.updateGroupValidationFormItems()
            }
            .width(.column(4))

        builder += item2!

        item3 = TextFieldFormItem()
            .title(NSLocalizedString("Engine Number", comment: "Title"))
            .placeholder(StringSizing(string: ""))
            .onValueChanged {
                self.finalVehicle.engineNumber = $0
                self.updateGroupValidationFormItems()
            }
            .width(.column(4))

        builder += item3!

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Vehicle Description", comment: "Description Section Header")).separatorColor(.clear)

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Year of Manufacture", comment: "Title"))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Year of Manufacture can only be number.", comment: "Validation Hint"))
            .onValueChanged { self.finalVehicle.year = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Make", comment: "Title"))
            .onValueChanged { self.finalVehicle.make = $0 }
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Required", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .width(.column(4))
            .onStyled { cell in
                guard let cell = cell as? CollectionViewFormTextFieldCell else { return }
                cell.textField.placeholderTextColor = cell.textField.textColor
            }

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Model", comment: "Title"))
            .onValueChanged { self.finalVehicle.model = $0 }
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Required", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .width(.column(4))
            .onStyled { cell in
                guard let cell = cell as? CollectionViewFormTextFieldCell else { return }
                cell.textField.placeholderTextColor = cell.textField.textColor
            }

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Primary Colour", comment: "Title"))
            .onValueChanged { self.finalVehicle.primaryColor = $0 }
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Required", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .width(.column(4))
            .onStyled { cell in
                guard let cell = cell as? CollectionViewFormTextFieldCell else { return }
                cell.textField.placeholderTextColor = cell.textField.textColor
            }

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Secondary Colour", comment: "Title"))
            .onValueChanged { self.finalVehicle.secondaryColor = $0 }
            .width(.column(4))

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Additional Details", comment: "Details Section Header")).separatorColor(.clear)

        builder += DropDownFormItem()
            .title(NSLocalizedString("Transmission", comment: "Drop Down Title"))
            .options(["Automatic", "Manual"])
            .onValueChanged { self.finalVehicle.transmission = $0?.first }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Seating Capacity", comment: "Title"))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Seating Capacity can only be number.", comment: "Validation Hint"))
            .onValueChanged {
                if let text = $0, let value = self.numberFormatter.number(from: text)?.intValue {
                    self.finalVehicle.seatingCapacity = value
                } else {
                    self.finalVehicle.seatingCapacity = nil
                }
            }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Gross Vehicle Mass", comment: "Title"))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Gross Vehicle Mass can only be number.", comment: "Validation Hint"))
            .onValueChanged {
                if let text = $0, let value = self.numberFormatter.number(from: text)?.intValue {
                    self.finalVehicle.weight = value
                } else {
                    self.finalVehicle.weight = nil
                }
            }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("TARE", comment: "Title"))
            .onValueChanged { self.finalVehicle.tare = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Remarks", comment: "Title"))
            .onValueChanged { self.finalVehicle.remarks = $0 }
            .width(.column(1))

    }

    // MARK: - Private

    @objc private func cancelButtonTapped(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func submitButtonTapped(_ item: UIBarButtonItem) {
        let isGroupInvalid = updateGroupValidationFormItems()
        let result = builder.validate()
        switch result {
        case .invalid:
            builder.validateAndUpdateUI()
        case .valid:
            guard isGroupInvalid else { return }
            do {
                try UserSession.current.userStorage?.addEntity(object: finalVehicle,
                                                               key: UserStorage.CreatedEntitiesKey,
                                                               notification: NSNotification.Name.CreatedEntitiesDidUpdate)
            } catch {
                // TODO: Handles error if it cannot be saved
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    @discardableResult
    private func updateGroupValidationFormItems() -> Bool {
        let isInvalid = self.finalVehicle.registration == nil || self.finalVehicle.registration?.count == 0
            && self.finalVehicle.vin == nil || self.finalVehicle.vin?.count == 0
            && self.finalVehicle.engineNumber == nil || self.finalVehicle.engineNumber?.count == 0
        self.item1?.cell?.setRequiresValidation(isInvalid, validationText: nil, animated: true)
        self.item2?.cell?.setRequiresValidation(isInvalid, validationText: nil, animated: true)
        self.item3?.cell?.setRequiresValidation(isInvalid, validationText: nil, animated: true)
        if let view = self.headerItem?.view as? CollectionViewFormHeaderView {
            view.tintColor = isInvalid ? UIColor.orangeRed : ThemeManager.shared.theme(for: .current).color(forKey: .secondaryText)
        }
        return isInvalid
    }

}
