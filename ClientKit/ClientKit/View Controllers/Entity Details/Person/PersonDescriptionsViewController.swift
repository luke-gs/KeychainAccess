//
//  PersonDescriptionsViewController.swift
//  Pods
//
//  Created by Gridstone on 6/6/17.
//
//

import UIKit
import MPOLKit

open class PersonDescriptionViewController: FormBuilderViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel: PersonDescriptionViewModel = {
        var vm = PersonDescriptionViewModel()
        vm.delegate = self
        return vm
    }()
    
    // MARK: - Lifecycle
    
    public init(descriptions: [PersonDescription]?) {
        super.init()
        title = viewModel.title
        viewModel.descriptions = descriptions
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func construct(builder: FormBuilder) {
        viewModel.construct(builder: builder)
    }
}

extension PersonDescriptionViewController: EntityDetailFormViewModelDelegate {
    
    public func reloadData() {
        reloadForm()
    }
}
