//
//  VehicleInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/3/17.
//
//

import UIKit
import MPOLKit

open class VehicleInfoViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        get { return viewModel.vehicle }
        set { self.viewModel.vehicle = newValue as? Vehicle}
    }
    
    private lazy var viewModel: VehicleInfoViewModel = {
        var vm = VehicleInfoViewModel()
        return vm
    }()
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Information", comment: "")
        
        sidebarItem.image = AssetManager.shared.image(forKey: .info)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("VehicleInfoViewController does not support NSCoding.")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityDetailCollectionViewCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = false
            
            headerView.text = viewModel.headerText(for: indexPath.section)
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = viewModel.section(at: indexPath.section)!
        
        let title: String?
        let subtitle: String?
        let multiLineSubtitle: Bool
        
        switch section {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            /// Temp updates
            cell.thumbnailView.configure(for: entity, size: .large)
            if cell.thumbnailView.allTargets.contains(self) == false {
                cell.thumbnailView.isEnabled = true
                cell.thumbnailView.addTarget(self, action: #selector(entityThumbnailDidSelect(_:)), for: .primaryActionTriggered)
            }
            
            return cell
        case .registration, .owner:
            let cellInfo = viewModel.cellInfo(for: section, at: indexPath)
            title    = cellInfo.title
            subtitle = cellInfo.subtitle
            multiLineSubtitle = cellInfo.multiLineSubtitle
        }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        cell.isEditable = false
        
        cell.titleLabel.text = title
        cell.valueLabel.text = subtitle
        cell.valueLabel.numberOfLines = multiLineSubtitle ? 0 : 1
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let detailCell = cell as? EntityDetailCollectionViewCell {
            detailCell.titleLabel.textColor       = primaryTextColor   ?? .black
            detailCell.subtitleLabel.textColor    = secondaryTextColor ?? .darkGray
            detailCell.descriptionLabel.textColor = secondaryTextColor ?? .darkGray
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        
        let extraLargeText: Bool
        
        switch traitCollection.preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large, UIContentSizeCategory.unspecified:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        
        let minimumWidth: CGFloat
        let maxColumnCount: Int
        
        let section = viewModel.section(at: indexPath.section)!

        switch section {
        case .header:
            return collectionView.bounds.width
        case .registration:
            switch viewModel.registrationItem(at: indexPath.item)! {
            case .make, .model, .vin:
                minimumWidth = extraLargeText ? 250.0 : 180.0
                maxColumnCount = 3
            default:
                minimumWidth = extraLargeText ? 180.0 : 115.0
                maxColumnCount = 4
            }
        case .owner:
            switch viewModel.owerItem(at: indexPath.item)! {
            case .address:
                return collectionView.bounds.width
            default:
                minimumWidth = extraLargeText ? 250.0 : 180.0
                maxColumnCount = 3
            }
        }
        
        return layout.columnContentWidth(forMinimumItemContentWidth: minimumWidth, maximumColumnCount: maxColumnCount, sectionEdgeInsets: sectionEdgeInsets).floored(toScale: traitCollection.currentDisplayScale)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let title: String
        let value: String
        
        let wantsMultiLineValue: Bool
        let section = viewModel.section(at: indexPath.section)!

        switch section {
        case .header:
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", descriptionPlaceholder: nil, additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
        case .registration:
            let regoItem = viewModel.registrationItem(at: indexPath.item)
            title = regoItem?.localizedTitle ?? ""
            value = regoItem?.value(from: nil) ?? ""
            wantsMultiLineValue = false
        case .owner:
            let ownerItem = viewModel.owerItem(at: indexPath.item)
            title    = ownerItem?.localizedTitle ?? ""
            value = ownerItem?.value(for: nil) ?? ""
            wantsMultiLineValue = ownerItem?.wantsMultiLineDetail ?? false
        }
        
        let valueSizing = StringSizing(string: value, numberOfLines: wantsMultiLineValue ? 0 : 1)
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: valueSizing, inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    
    // MARK: - Private
    
    
    @objc private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
        
    }
}
