//
//  PersonInfoViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class PersonInfoViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        get {
            return self.viewModel.person
        }
        set {
            self.viewModel.person = newValue as? Person
            updateLoadingManagerState()
        }
    }
    
    private lazy var viewModel: PersonInfoViewModel = {
        let vm = PersonInfoViewModel()
        vm.delegate = self
        return vm
    }()
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Information", bundle: .mpolKit, comment: "")
        
        sidebarItem.image = AssetManager.shared.image(forKey: .info)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("PersonInfoViewController does not support NSCoding.")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let noContentView = loadingManager.noContentView
        noContentView.titleLabel.text = NSLocalizedString("No Person Found", bundle: .mpolKit, comment: "")
        noContentView.subtitleLabel.text = NSLocalizedString("There are no details for this person", bundle: .mpolKit, comment: "")
        
        loadingManager.loadingLabel.text = "Retrieving records"
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityDetailCollectionViewCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormProgressCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)

            let showExpandArrow = indexPath.section > 0
            headerView.showsExpandArrow = showExpandArrow
            if showExpandArrow {
                headerView.tapHandler = { [weak self] header, indexPath in
                    guard let `self` = self else { return }

                    let section = indexPath.section

                    self.viewModel.updateCollapsedSections(for: [section])
                    headerView.setExpanded(self.viewModel.isSectionExpanded(section: section), animated: true)
                    collectionView.reloadSections(IndexSet(integer: section))
                }
                headerView.isExpanded = self.viewModel.isSectionExpanded(section: indexPath.section)
            }

            headerView.text = viewModel.header(for: indexPath.section)
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = viewModel.item(at: indexPath.section)!
        
        let title: String?
        let value: String?
        let image: UIImage?

        switch section.type {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            let headerCellInfo = viewModel.headerCellInfo()
            cell.thumbnailView.configure(for: headerCellInfo.person, size: .large)
            
            // TODO: - Needs to remove the mock, once real data is hooked up
            /// cell.thumbnailView.imageView.image = #imageLiteral(resourceName: "Avatar 1")
            
            // TODO: ?
//            if cell.thumbnailView.allTargets.contains(self) == false {
//                cell.thumbnailView.isEnabled = true
//                cell.thumbnailView.addTarget(self, action: #selector(entityThumbnailDidSelect(_:)), for: .primaryActionTriggered)
//            }
            
            cell.sourceLabel.text          = headerCellInfo.source
            cell.titleLabel.text           = headerCellInfo.title
            cell.subtitleLabel.text        = headerCellInfo.subtitle
            cell.descriptionLabel.text     = headerCellInfo.description
            cell.isDescriptionPlaceholder  = headerCellInfo.isDescriptionPlaceholder
            cell.additionalDetailsButton.setTitle(headerCellInfo.additionalDetailsButtonTitle, for: .normal)
            
            return cell
        case .details, .addresses, .contact:
            let cellInfo = viewModel.cellInfo(for: section, at: indexPath)
            title = cellInfo.title
            value = cellInfo.value
            image = cellInfo.image
        case .aliases:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            let cellInfo = viewModel.cellInfo(for: section, at: indexPath)
            cell.titleLabel.text = cellInfo.title
            cell.subtitleLabel.text = cellInfo.subtitle
            cell.subtitleLabel.numberOfLines = 1
            cell.imageView.image = cellInfo.image
            return cell
        case .licence(_):
            let cellInfo = viewModel.cellInfo(for: section, at: indexPath)
            
            title = cellInfo.title
            value = cellInfo.value
            image = cellInfo.image
            
            if let validity = cellInfo.isProgressCell, validity == true {
                let progressCell = collectionView.dequeueReusableCell(of: CollectionViewFormProgressCell.self, for: indexPath)
                progressCell.imageView.image = image
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
        cell.imageView.image = image?.withRenderingMode(.alwaysTemplate)
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let detailCell = cell as? EntityDetailCollectionViewCell {
            detailCell.titleLabel.textColor       = primaryTextColor   ?? .black
            detailCell.subtitleLabel.textColor    = secondaryTextColor ?? .darkGray
            detailCell.descriptionLabel.textColor = detailCell.isDescriptionPlaceholder ? placeholderTextColor ?? .lightGray : secondaryTextColor ?? .darkGray
        }
        
        if let subtitleCell = cell as? CollectionViewFormSubtitleCell {
            subtitleCell.titleLabel.textColor = secondaryTextColor
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        
        let section = viewModel.item(at: indexPath.section)!

        switch section.type {
        case .contact, .details:
            return layout.columnContentWidth(forMinimumItemContentWidth: 250.0, maximumColumnCount: 2, sectionEdgeInsets: sectionEdgeInsets).floored(toScale: traitCollection.currentDisplayScale)
        case .licence(_):
            let columns = viewModel.licenceItemFillingColumns(at: indexPath)
            
            let columnCount = max(min(layout.columnCountForSection(withMinimumItemContentWidth: 180.0, sectionEdgeInsets: sectionEdgeInsets), 3), 1)
            return layout.itemContentWidth(fillingColumns: columns, inSectionWithColumns: columnCount, sectionEdgeInsets: sectionEdgeInsets)
        default:
            return collectionView.bounds.width
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        
        let section = viewModel.item(at: indexPath.section)!
        
        let wantsSingleLineValue: Bool
        let title: String?
        let value: String?
        let image: UIImage?
        
        switch section.type {
        case .header:
            let headerInfo = viewModel.headerInfoForMinimumContentHeight()
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: headerInfo.title,
                                                                       subtitle: headerInfo.subtitle,
                                                                       description: headerInfo.description,
                                                                       descriptionPlaceholder: headerInfo.placeholder,
                                                                       additionalDetails: headerInfo.additionalDetails,
                                                                       source: headerInfo.source,
                                                                       inWidth: itemWidth,
                                                                       compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
      
        case .aliases:
            let itemInfo = viewModel.itemInforForMinimumContentHeight(at: indexPath)
            title = itemInfo.title
            value = itemInfo.value
            image = itemInfo.image
            
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: value, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero)
        case .details, .addresses, .contact, .licence(_):
            let itemInfo = viewModel.itemInforForMinimumContentHeight(at: indexPath)
            
            title = itemInfo.title
            value = itemInfo.value
            image = itemInfo.image
            wantsSingleLineValue = itemInfo.wantsSingleLineValue!
        }
        
        let valueSizing = StringSizing(string: value ?? "", numberOfLines: wantsSingleLineValue ? 1 : 0)
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: valueSizing, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero)
    }

    
    @objc private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
        guard let navController = pushableSplitViewController?.navigationController ?? navigationController else { return }
        let moreDescriptionsVC = PersonDescriptionsViewController()
        moreDescriptionsVC.descriptions = viewModel.personDescriptions
        navController.pushViewController(moreDescriptionsVC, animated: true)
    }
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
    }
    
    private func updateLoadingManagerState() {
        loadingManager.state = entity != nil ? .loaded : .noContent
    }

}

extension PersonInfoViewController: EntityDetailViewModelDelegate {

   public func reloadData() {
        collectionView?.reloadData()
    }

}
