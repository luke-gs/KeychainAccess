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

    // MARK: - Reference

    public let initialVehicle: Vehicle?

    // MARK: - Storage

    private let finalVehicle = Vehicle(id: UUID().uuidString)

    public init(initialVehicle: Vehicle? = nil) {
        self.initialVehicle = initialVehicle
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitButtonTapped(_:)))
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func construct(builder: FormBuilder) {
        builder.title = NSLocalizedString("Create New Vehicle", comment: "Title")

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("General", comment: "General Section Header")).separatorColor(.clear)

        builder += DropDownFormItem()
            .title(NSLocalizedString("Vehicle Type", comment: "Drop Down Title"))
            .options(["Car", "Motorcycle", "Van", "Truck", "Trailer", "Vessel"])
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Registration Number", comment: "Vehicle Number"))
            .onValueChanged { $0 }
            .required()
            .width(.column(4))

        builder += DropDownFormItem()
            .title(NSLocalizedString("State", comment: "Drop Down Title"))
            .options(["VIC", "NSW", "QLD", "ACT", "NT", "WA", "TAS"])
            .onValueChanged { $0 }
            .width(.column(4))

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: "Details Section Header")).separatorColor(.clear)

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Year of Manufacture", comment: ""))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Year of Manufacture can only be number.", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Make", comment: ""))
            .onValueChanged { $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Model", comment: ""))
            .onValueChanged { $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("VIN/Chassis Number", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Engine Number", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Fuel Number", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Primary Colour", comment: ""))
            .onValueChanged { $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Secondary Colour", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

        builder += DropDownFormItem()
            .title(NSLocalizedString("Transmission", comment: "Drop Down Title"))
            .options(["Automatic", "Manual"])
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Gross Vehicle Mass", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("TARE", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Seating Capacity", comment: ""))
            .onValueChanged { $0 }
            .width(.column(4))

    }

    // MARK: - Private

    @objc private func cancelButtonTapped(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func submitButtonTapped(_ item: UIBarButtonItem) {
        let result = builder.validate()
        switch result {
        case .invalid:
            builder.validateAndUpdateUI()
        case .valid:
            self.dismiss(animated: true, completion: nil)
        }
    }

}
