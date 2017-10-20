//
//  CADStatusTabBarController.swift
//  ClientKit
//
//  Created by Kyle May on 8/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// CAD implementation of status tab bar with book-on status
open class CADStatusTabBarController: StatusTabBarController {
    
    open let viewModel: CADStatusTabBarViewModel
    open var bookOnStatusView: BookOnStatusView!
    
    public init(viewModel: CADStatusTabBarViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Add book on status view to status area
        bookOnStatusView = viewModel.bookOnStatusViewModel.createView()
        bookOnStatusView.addTarget(self, action: #selector(selectedBookOnStatusView), for: .touchUpInside)
        
        statusView = bookOnStatusView
        tabBar.isTranslucent = false
    }
    
    @objc open func selectedBookOnStatusView() {
        guard let viewController = viewModel.bookOnStatusViewModel.createActionViewController() else { return }
        
        let container = PopoverNavigationController(rootViewController: viewController)
        container.modalPresentationStyle = .formSheet
        
        selectedViewController?.present(container, animated: true)
    }
}

extension CADStatusTabBarController: BookOnStatusViewModelDelegate {
    public func viewModelStateChanged() {
        bookOnStatusView.updateViews()
    }
}
