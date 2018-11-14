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
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Registration Number", comment: "Vehicle Number"))
            .onValueChanged { self.finalVehicle.registration = $0 }
            .required()
            .width(.column(4))

        builder += DropDownFormItem()
            .title(NSLocalizedString("State", comment: "Drop Down Title"))
            .options(["VIC", "NSW", "QLD", "ACT", "NT", "WA", "TAS"])
            .onValueChanged { self.finalVehicle.registrationState = $0?.first }
            .width(.column(4))

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: "Details Section Header")).separatorColor(.clear)

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Year of Manufacture", comment: "Title"))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Year of Manufacture can only be number.", comment: "Validation Hint"))
            .onValueChanged { self.finalVehicle.year = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Make", comment: "Title"))
            .onValueChanged { self.finalVehicle.make = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Model", comment: "Title"))
            .onValueChanged { self.finalVehicle.model = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("VIN/Chassis Number", comment: "Title"))
            .onValueChanged { self.finalVehicle.vin = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Engine Number", comment: "Title"))
            .onValueChanged { self.finalVehicle.engineNumber = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Fuel Type", comment: "Title"))
            .onValueChanged { _ = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Primary Colour", comment: "Title"))
            .onValueChanged { self.finalVehicle.primaryColor = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Secondary Colour", comment: "Title"))
            .onValueChanged { self.finalVehicle.secondaryColor = $0 }
            .width(.column(4))

        builder += DropDownFormItem()
            .title(NSLocalizedString("Transmission", comment: "Drop Down Title"))
            .options(["Automatic", "Manual"])
            .onValueChanged { self.finalVehicle.transmission = $0?.first }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Gross Vehicle Mass", comment: "Title"))
            .onValueChanged { _ = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("TARE", comment: "Title"))
            .onValueChanged { _ = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Seating Capacity", comment: "Title"))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Seating Capacity can only be number.", comment: "Validation Hint"))
            .onValueChanged {
                self.finalVehicle.seatingCapacity = $0 != nil ? Int($0!) : nil
            }
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

}
