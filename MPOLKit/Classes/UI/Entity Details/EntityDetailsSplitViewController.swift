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
    
    public let headerTitleLabel: UILabel = UILabel(frame: .zero)
    
    public let headerSubtitleLabel: UILabel = UILabel(frame: .zero)
    
    public init(entity: Any) {
        self.entity = entity
        
        let detailVCs: [UIViewController] = [
            OrganizationInfoViewController(),
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
        
        // Create header view
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 60.0))
        headerView.preservesSuperviewLayoutMargins = true
        headerView.accessibilityTraits |= UIAccessibilityTraitHeader
        
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.adjustsFontSizeToFitWidth = true
        headerTitleLabel.numberOfLines = 0
        headerTitleLabel.text = "Frost, Deacon R."
        headerTitleLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        headerTitleLabel.textColor = .white
        
        headerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitleLabel.adjustsFontSizeToFitWidth = true
        headerSubtitleLabel.numberOfLines = 0
        headerSubtitleLabel.text = "#560285012"
        headerSubtitleLabel.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        
        updateHeaderFonts()
        
        headerView.addSubview(headerSubtitleLabel)
        headerView.addSubview(headerTitleLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: headerTitleLabel, attribute: .top,     relatedBy: .equal, toItem: headerView, attribute: .top, constant: 22.0),
            NSLayoutConstraint(item: headerTitleLabel, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leadingMargin),
            NSLayoutConstraint(item: headerTitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: headerView, attribute: .trailingMargin),
            
            NSLayoutConstraint(item: headerSubtitleLabel, attribute: .top,      relatedBy: .equal, toItem: headerTitleLabel, attribute: .bottom, constant: 5.0),
            NSLayoutConstraint(item: headerSubtitleLabel, attribute: .leading,  relatedBy: .equal, toItem: headerView,       attribute: .leadingMargin),
            NSLayoutConstraint(item: headerSubtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: headerView, attribute: .trailingMargin),
            NSLayoutConstraint(item: headerSubtitleLabel, attribute: .bottom,   relatedBy: .equal, toItem: headerView,       attribute: .bottom, constant: -20.0, priority: UILayoutPriorityRequired - 1),
        ])
        
        sidebarViewController.headerView = headerView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidActivate(_:)), for: .primaryActionTriggered)
        sidebarViewController.loadViewIfNeeded()
        if #available(iOS 10, *) {
            sidebarViewController.sidebarTableView?.refreshControl = refreshControl
        } else {
            sidebarViewController.sidebarTableView?.addSubview(refreshControl)
            NotificationCenter.default.addObserver(self, selector: #selector(updateHeaderFonts), name: .UIContentSizeCategoryDidChange, object: nil)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard #available(iOS 10, *) else { return }
        
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            updateHeaderFonts()
        }
    }
    
    
    // MARK: - Private methods
    
    @objc private func updateHeaderFonts() {
        let headerSubtitleDescriptor: UIFontDescriptor
        if #available(iOS 10, *) {
            headerSubtitleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline, compatibleWith: traitCollection)
        } else {
            headerSubtitleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        }
        headerSubtitleLabel.font = UIFont(descriptor: headerSubtitleDescriptor, size: headerSubtitleDescriptor.pointSize - 1.0)
    }
    
    @objc private func refreshControlDidActivate(_ control: UIRefreshControl) {
        
        
        // TODO: Actually refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { 
            control.endRefreshing()
        }
        
    }
    
}
