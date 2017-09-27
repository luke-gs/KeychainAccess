//
//  ActivityLogViewController.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

public class ActivityLogViewController: UITableViewController {

    private lazy var viewModel: ActivityLogViewModel = {
        let vm = ActivityLogViewModel()
        // vm.delegate = self
        return vm
    }()

    // MARK: - Initializers

    public init() {
        super.init(style: .grouped)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.navTitle()
    }

}
