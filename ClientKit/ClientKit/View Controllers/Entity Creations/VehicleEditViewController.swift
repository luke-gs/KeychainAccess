//
//  VehicleEditViewController.swift
//  ClientKit
//
//  Created by KGWH78 on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

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
        builder.title = "Vehicle"

        builder += HeaderFormItem(text: "DETAILS")

        builder += TextFieldFormItem().title("Registration Number")
            .required()
            .width(.column(2))

        builder += DropDownFormItem()
            .title("Registration State")
            .options(["VIC", "NSW", "QLD", "ACT", "NT", "WA", "TAS"])
            .required()
            .width(.column(2))

        builder += HeaderFormItem(text: "DESCRIPTION")

        builder += TextFieldFormItem()
            .title("VIN")
            .onValueChanged { self.finalVehicle.vin = $0 }
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Engine Number")
            .onValueChanged { self.finalVehicle.engineNumber = $0 }
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Make")
            .onValueChanged { self.finalVehicle.make = $0 }
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Model")
            .onValueChanged { self.finalVehicle.model = $0 }
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Year")
            .onValueChanged { self.finalVehicle.year = $0 }
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Type")
            .onValueChanged { self.finalVehicle.vehicleType = $0 }
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Body Type")
            .onValueChanged { self.finalVehicle.bodyType = $0 }
            .width(.column(2))

        builder += DropDownFormItem()
            .options(["White", "Black", "Silver", "Gray", "Yellow", "Red", "Green", "Blue", "Brown"])
            .title("Colour")
            .onValueChanged { self.finalVehicle.primaryColor = $0?.first }
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Remarks")
            .placeholder("eg. decals, modifications or damage.")
            .onValueChanged { self.finalVehicle.remarks = $0 }
            .width(.column(1))

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
            UserSession.current.recentlyActioned.add(finalVehicle)
            self.dismiss(animated: true, completion: nil)
            break
        }
    }

}


