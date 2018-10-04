//
//  AddressViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PromiseKit

public class AddressViewController: SubmissionFormBuilderViewController {
    
    public var submitHandler: ((AddressViewModel) -> Promise<Void>)?
    public var closeHandler: ((Bool) -> Void)?
    
    public let viewModel: AddressViewModel
    
    public init(viewModel: AddressViewModel) {
        self.viewModel = viewModel
        super.init()
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - View lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Select Location", comment: "")
    }
    
    // MARK: - SubmissiomFormBuilderViewController
    
    public override var submitText: String {
        return AssetManager.shared.string(forKey: .submitFormDone)
    }
    
    public override func construct(builder: FormBuilder) {
        
        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: "")).separatorColor(.clear)
        
        builder += ValueFormItem(title: NSLocalizedString("Address", comment: ""),
                                 value: self.viewModel.fullAddress)
            .width(.column(1))
            .separatorColor(.clear)
        
        builder += ValueFormItem(title: NSLocalizedString("Latitude, Longitude", comment: ""),
                                 value: self.viewModel.coords)
            .width(.column(1))
            .separatorColor(.clear)
        
        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Location Information", comment: "")).separatorColor(.clear)
        
        // editable
        
        if self.viewModel.isEditable {
            
            builder += TextFieldFormItem(title: NSLocalizedString("Unit / House / Apt. Number", comment: ""))
                .text(self.viewModel.propertyNumber)
                .onValueChanged { [unowned self] in
                    self.viewModel.propertyNumber = $0
                }
                .width(.column(2))
            builder += TextFieldFormItem(title: NSLocalizedString("Street Number / Range", comment: ""))
                .text(self.viewModel.streetNumber)
                .onValueChanged { [unowned self] in
                    self.viewModel.remarks = $0
                }
                .width(.column(2))
            builder += TextFieldFormItem(title: NSLocalizedString("Street Name", comment: ""))
                .required()
                .text(self.viewModel.streetName)
                .onValueChanged { [unowned self] in
                    self.viewModel.streetName = $0
                }
                .width(.column(2))
            builder += DropDownFormItem(title: NSLocalizedString("Street Type", comment: ""))
                .options(self.viewModel.streetTypeOptions)
                .selectedValue([self.viewModel.streetType ?? AnyPickable("")])
                .allowsMultipleSelection(false)
                .onValueChanged { [unowned self] in
                    self.viewModel.streetType = $0?.first
                }
                .width(.column(2))
            builder += DropDownFormItem(title: NSLocalizedString("Suburb", comment: ""))
                .options(self.viewModel.suburbOptions)
                .selectedValue([self.viewModel.suburb ?? AnyPickable("")])
                .allowsMultipleSelection(false)
                .onValueChanged { [unowned self] in
                    self.viewModel.suburb = $0?.first
                }
                .width(.column(2))
            builder += DropDownFormItem(title: NSLocalizedString("State", comment: ""))
                .options(self.viewModel.stateOptions)
                .selectedValue([self.viewModel.state ?? AnyPickable("")])
                .allowsMultipleSelection(false)
                .onValueChanged { [unowned self] in
                    self.viewModel.state = $0?.first
                }
                .width(.column(2))
            builder += TextFieldFormItem(title: NSLocalizedString("Postcode", comment: ""))
                .text(self.viewModel.postcode)
                .onValueChanged { [unowned self] in
                    self.viewModel.postcode = $0
                }
                .width(.column(2))
        } else {
            // non-editable
            
            builder += ValueFormItem(title: NSLocalizedString("Unit / House / Apt. Number", comment: ""),
                                     value: self.viewModel.propertyNumber)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Street Number / Range", comment: ""),
                                     value: self.viewModel.streetNumber)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Street Name", comment: ""),
                                     value: self.viewModel.streetName)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Street Type", comment: ""),
                                     value: self.viewModel.streetType?.title)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Suburb", comment: ""),
                                     value: self.viewModel.suburb?.title)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("State", comment: ""),
                                     value: self.viewModel.state?.title)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Postcode", comment: ""),
                                     value: self.viewModel.postcode)
                .width(.column(2))
                .separatorColor(.clear)
        }
        
        builder += TextFieldFormItem(title: NSLocalizedString("Remarks", comment: ""))
            .onValueChanged { [unowned self] in
                self.viewModel.remarks = $0
            }
            .width(.column(1))
        
        if self.viewModel.involvement != nil || self.viewModel.isEditable {
            // only display when involvment exists or it is an editable form
            builder += DropDownFormItem()
                .title(NSLocalizedString("Involvement/s", comment: ""))
                .options(self.viewModel.involvementOptions)
                .selectedValue([self.viewModel.involvement ?? AnyPickable("")])
                .required()
                .accessory(ItemAccessory.disclosure)
                .width(.column(1))
        }
    }
    
    public override func performSubmit() -> Promise<Void> {
        return submitHandler?(self.viewModel) ?? Promise<Void>()
    }
    
    public override func performClose(submitted: Bool) {
        closeHandler?(submitted)
    }
    
}
