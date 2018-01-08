//
//  VehicleInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/3/17.
//
//

import UIKit
import MPOLKit

open class VehicleInfoViewController: FormCollectionViewController, EntityDetailSectionUpdatable {
    
    open var genericEntity: MPOLKitEntity? {
        get {
            return viewModel.vehicle
        }
        set {
            self.viewModel.vehicle = newValue as? Vehicle
            updateLoadingManagerState()

        }
    }
    
    private lazy var viewModel: VehicleInfoViewModel = {
        var vm = VehicleInfoViewModel()
        vm.delegate = self
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
        collectionView.register(CollectionViewFormProgressCell.self)

    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = true

            headerView.tapHandler = { [weak self] header, indexPath in
                guard let `self` = self else { return }

                let section = indexPath.section

                self.viewModel.updateCollapsed(for: [section])
                headerView.setExpanded(self.viewModel.isExpanded(at: section), animated: true)
                collectionView.reloadSections(IndexSet(integer: section))
            }

            headerView.isExpanded = self.viewModel.isExpanded(at: indexPath.section)
            headerView.text = viewModel.header(for: indexPath.section)
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = viewModel.item(at: indexPath.section)!
        
        let title: String?
        let value: String?
        let multiLineSubtitle: Bool
        
        switch section.type {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            let headerCellInfo = viewModel.headerCellInfo()
            
            /// Temp updates
            cell.thumbnailView.configure(for: headerCellInfo.vehicle, size: .large)

            if cell.thumbnailView.allTargets.contains(self) == false {
                cell.thumbnailView.isEnabled = true
                cell.thumbnailView.addTarget(self, action: #selector(entityThumbnailDidSelect(_:)), for: .primaryActionTriggered)
            }
            
            cell.sourceLabel.text          = headerCellInfo.vehicle?.category
            cell.titleLabel.text           = headerCellInfo.vehicle?.title
            cell.subtitleLabel.text        = headerCellInfo.vehicle?.detail1
            cell.descriptionLabel.text     = headerCellInfo.description
            
            return cell
        case .registration:
            let cellInfo = viewModel.cellInfo(for: section, at: indexPath)
            title = cellInfo.title
            value = cellInfo.value
            multiLineSubtitle = cellInfo.multiLineSubtitle
            
            if let validity = cellInfo.isProgressCell, validity == true {
                let progressCell = collectionView.dequeueReusableCell(of: CollectionViewFormProgressCell.self, for: indexPath)
                progressCell.imageView.image = nil
                progressCell.titleLabel.text = title
                progressCell.valueLabel.text = value
                progressCell.isEditable = cellInfo.isEditable!
                
                if let progress = cellInfo.progress {
                    progressCell.progressView.progress = progress
                    progressCell.progressView.progressTintColor = cellInfo.progressTintColor
                }
                progressCell.progressView.isHidden = cellInfo.isProgressViewHidden!
                
                return progressCell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        cell.isEditable = false
        
        cell.titleLabel.text = title
        cell.valueLabel.text = value
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
        
        let section = viewModel.item(at: indexPath.section)!

        switch section.type {
        case .header:
            return collectionView.bounds.width
        case .registration:
            switch viewModel.registrationItem(at: indexPath.item)! {
            case .validity:
                minimumWidth = extraLargeText ? 250.0 : 180.0
                maxColumnCount = 2
            default:
//                minimumWidth = extraLargeText ? 180.0 : 115.0
//                maxColumnCount = 4
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
        let section = viewModel.item(at: indexPath.section)!

        switch section.type {
        case .header:
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", descriptionPlaceholder: nil, additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
        case .registration:
            let regoItem = viewModel.registrationItem(at: indexPath.item)
            title = regoItem?.localizedTitle ?? ""
            value = regoItem?.value(from: nil) ?? ""
            wantsMultiLineValue = false
//        case .owner:
//            let ownerItem = viewModel.owerItem(at: indexPath.item)
//            title    = ownerItem?.localizedTitle ?? ""
//            value = ownerItem?.value(for: nil) ?? ""
//            wantsMultiLineValue = ownerItem?.wantsMultiLineDetail ?? false
        }
        
        let valueSizing = StringSizing(string: value, numberOfLines: wantsMultiLineValue ? 0 : 1)
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: valueSizing, inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    
    // MARK: - Private
    
    
    @objc private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
        
    }
    
    private func updateLoadingManagerState() {
        loadingManager.state = genericEntity != nil ? .loaded : .noContent
    }
}

extension VehicleInfoViewController: EntityDetailViewModelDelegate {
    public func reloadData() {
        collectionView?.reloadData()
    }
}
