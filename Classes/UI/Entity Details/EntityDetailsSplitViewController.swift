//
//  EntityDetailsSplitViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityDetailsSplitViewController: SidebarSplitViewController {
    
    public var entity: Any
    
    public let headerView: EntityDetailsSidebarHeaderView = EntityDetailsSidebarHeaderView(frame: .zero)
    
    public init(entity: Any) {
        self.entity = entity
        
        let detailVCs: [UIViewController] = [
            VehicleInfoViewController(),
            EntityAlertsViewController(),
            EntityAssociationsViewController(),
            EntityOccurrencesViewController()
        ]
        
        super.init(detailViewControllers: detailVCs)
        
        title = "Details"
        
        sidebarViewController.sourceItems = [SourceItem(title: "DS1", state: .notLoaded)]
        
        let formForwardIcon = UIImage(named: "iconFormForward", in: .mpolKit, compatibleWith: nil)
        
        sidebarViewController.title = "Details"
        sidebarViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: formForwardIcon, style: .plain, target: nil, action:  nil)
        sidebarViewController.headerView = headerView
        
        headerView.typeLabel.text        = "PERSON"
        headerView.titleLabel.text       = "Citizen, John R."
        headerView.lastUpdatedLabel.text = "Last Updated: 27/02/16"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidActivate(_:)), for: .primaryActionTriggered)
        sidebarViewController.loadViewIfNeeded()
        if #available(iOS 10, *) {
            sidebarViewController.sidebarTableView?.refreshControl = refreshControl
        } else {
            sidebarViewController.sidebarTableView?.addSubview(refreshControl)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func refreshControlDidActivate(_ control: UIRefreshControl) {
        
        
        // TODO: Actually refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { 
            control.endRefreshing()
        }
        
    }
    
}
