//
//  EventsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 29/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class EventsListViewController: FormCollectionViewController {
    
    private static let eventIcon = AssetManager.shared.image(forKey: .event)
    
    override init() {
        super.init()
        title = NSLocalizedString("Events", comment: "Title")
        
        tabBarItem.image = AssetManager.shared.image(forKey: .tabBarEvents)
        //tabBarItem.isEnabled = false
        
        updateNewBarButtonItem()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionView = self.collectionView!
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(EventListFooterView.self, forSupplementaryViewOfKind: collectionElementKindGlobalFooter)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            collectionView?.reloadData() // we need to reload the cells because their action labels will show/hide
            updateNewBarButtonItem()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            view.text = "2 " + (indexPath.section == 0 ? "DRAFTS" : "QUEUED")
            return view
        case collectionElementKindGlobalFooter:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: EventListFooterView.self, for: indexPath)
            view.captionLabel.text = NSLocalizedString("Last attempted to submit at 10:30 AM", comment: "") // TODO: Fix this temp value
            view.button.setTitle(NSLocalizedString("TRY AGAIN NOW", comment: ""), for: .normal)
            
            // TODO: Use directionalEdgeInsets in iOS 11
            if traitCollection.layoutDirection == .rightToLeft {
                view.layoutMargins.right = 24.0
            } else {
                view.layoutMargins.left = 24.0
            }
            
            return view
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.titleLabel.text = "Street Check"
        cell.subtitleLabel.text = "4-12 Langridge St, Collingwood VIC 3066"
        cell.imageView.image = EventsListViewController.eventIcon
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        
        let labeledAccessory: LabeledAccessoryView
        if let currentAccessory = cell.accessoryView as? LabeledAccessoryView {
            labeledAccessory = currentAccessory
        } else {
            labeledAccessory = LabeledAccessoryView(frame: .zero)
            labeledAccessory.titleLabel.font = .preferredFont(forTextStyle: .subheadline)
            labeledAccessory.accessoryView = FormDisclosureView()
        }
        labeledAccessory.titleLabel.text = isCompact ? nil : "Open Event"
        labeledAccessory.subtitleLabel.text = isCompact ? nil : "Saved at 8:45 AM"
        cell.accessoryView = labeledAccessory
        cell.highlightStyle = .fade
        
        return cell
    }
    
    
    // MARK: - Collection view delegate
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let accessory = (cell as? CollectionViewFormCell)?.accessoryView as? LabeledAccessoryView {
            accessory.titleLabel.textColor = collectionView.tintColor
            accessory.subtitleLabel.textColor = secondaryTextColor
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        
        if let footer = view as? EventListFooterView {
            footer.captionLabel.textColor = secondaryTextColor
        }
    }
    
    
    // MARK: - Collection view delegate form layout
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForGlobalFooterInLayout layout: CollectionViewFormLayout) -> CGFloat {
        return 36.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Street Check", subtitle: "4-12 Langridge St, Collingwood VIC 3066", inWidth: itemWidth, compatibleWith: traitCollection, imageSize: EventsListViewController.eventIcon?.size ?? .zero, accessoryViewSize: FormDisclosureView.standardSize)
    }
    
    
    // MARK: - Private methods
    
    private func updateNewBarButtonItem() {
        if traitCollection.horizontalSizeClass == .compact {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("New Event", comment: "Bar button title"), style: .plain, target: nil, action: nil)
        }
    }
    
}


private class EventListFooterView: UICollectionReusableView, DefaultReusable {
    
    let captionLabel = UILabel(frame: .zero)
    
    let button = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        captionLabel.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        
        let font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: traitCollection)
        captionLabel.font = font
        
        addSubview(captionLabel)
        addSubview(button)
        
        let layoutMarginsGuide = self.layoutMarginsGuide
        
        var constraints = [
            captionLabel.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            captionLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).withPriority(UILayoutPriorityDefaultLow),
            captionLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            captionLabel.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            
            button.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            button.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: captionLabel.trailingAnchor, constant: 8.0),
            button.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            button.firstBaselineAnchor.constraint(equalTo: captionLabel.firstBaselineAnchor)
        ]
        
        if let buttonLabel = button.titleLabel {
            buttonLabel.font = font
            constraints.append(captionLabel.firstBaselineAnchor.constraint(equalTo: buttonLabel.firstBaselineAnchor))
        } else {
            constraints.append(captionLabel.topAnchor.constraint(equalTo: button.topAnchor))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutMargins = (layoutAttributes as? CollectionViewFormLayoutAttributes)?.layoutMargins ?? UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
    
    public final override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
}
