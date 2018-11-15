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

    // MARK: - PRIVATE
    private let numberFormatter = NumberFormatter()

    // Group validation form items
    private var groupHeaderItem: HeaderFormItem?
    private var registrationItem: TextFieldFormItem?
    private var vinItem: TextFieldFormItem?
    private var engineNumberItem: TextFieldFormItem?

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

        groupHeaderItem = HeaderFormItem()
            .text(NSLocalizedString("AT LEAST ONE OF THE FIELDS BELOW ARE REQUIRED", comment: "Header for group validation"))
        builder += groupHeaderItem!

        registrationItem = TextFieldFormItem()
            .title(NSLocalizedString("Registration Number", comment: "Vehicle Number"))
            .placeholder(StringSizing(string: ""))
            .onValueChanged {
                self.finalVehicle.registration = $0
                self.validateGroup()
            }
            .width(.column(4))

        builder += registrationItem!

        vinItem = TextFieldFormItem()
            .title(NSLocalizedString("VIN/Chassis Number", comment: "Title"))
            .placeholder(StringSizing(string: ""))
            .onValueChanged {
                // map both VIN and Chassis Number to vin
                self.finalVehicle.vin = $0
                self.validateGroup()
            }
            .width(.column(4))

        builder += vinItem!

        engineNumberItem = TextFieldFormItem()
            .title(NSLocalizedString("Engine Number", comment: "Title"))
            .placeholder(StringSizing(string: ""))
            .onValueChanged {
                self.finalVehicle.engineNumber = $0
                self.validateGroup()
            }
            .width(.column(4))

        builder += engineNumberItem!

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
        let result = builder.validate()
        let isGroupInvalid = validateGroup()
        switch result {
        case .invalid:
            builder.validateAndUpdateUI()
        case .valid where !isGroupInvalid:
            do {
                try UserSession.current.userStorage?.addEntity(object: finalVehicle,
                                                               key: UserStorage.CreatedEntitiesKey,
                                                               notification: NSNotification.Name.CreatedEntitiesDidUpdate)
            } catch {
                // TODO: Handles error if it cannot be saved
            }
            self.dismiss(animated: true, completion: nil)
        default:
            // others are valid except the group
            break
        }

    }

    @discardableResult
    /// Manually validate the group of form items
    /// - Returns: true if group is invalid
    private func validateGroup() -> Bool {
        let isInvalid = finalVehicle.registration?.isEmpty ?? true
            && finalVehicle.vin?.isEmpty ?? true
            && finalVehicle.engineNumber?.isEmpty ?? true
        // force to show focused text by executing a reload
        registrationItem!.focused(isInvalid).reloadItem()
        vinItem!.focused(isInvalid).reloadItem()
        engineNumberItem!.focused(isInvalid).reloadItem()

        // force the header to be red if invalid
        if let view = self.groupHeaderItem?.view as? CollectionViewFormHeaderView {
            view.tintColor = isInvalid
                ? UIColor.orangeRed
                : ThemeManager.shared.theme(for: .current).color(forKey: .secondaryText)
        }

        return isInvalid
    }

}
