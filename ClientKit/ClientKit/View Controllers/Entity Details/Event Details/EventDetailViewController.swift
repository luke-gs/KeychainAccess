//
//  EventDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 26/5/17.
//
//

import UIKit
import MPOLKit

open class EventDetailViewController: FormCollectionViewController {
    
    // MARK: - Public properties
    
    /// The event to display. The default is `nil`.
    open var event: Event? {
        didSet {
        //    updateSections()
            viewModel = EventDetailsViewModelRouter.getViewModel(for: event!)!
        }
    }
    
    open var viewModel: EventDetailsViewModel!
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
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
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            view.showsExpandArrow = false
            
            view.text = viewModel.title(for: indexPath.section)
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel.item(at: indexPath)!
        
        switch item.style {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.imageView.image    = item.image
            cell.subtitleLabel.text = item.detail
            cell.titleLabel.text    = item.title
            cell.titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
            cell.titleLabel.numberOfLines = 0

            return cell
        case .item:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.imageView.image    = item.image
            cell.subtitleLabel.text = item.detail
            cell.titleLabel.text    = item.title
            cell.titleLabel.numberOfLines = 0
            cell.titleLabel.font = .preferredFont(forTextStyle: .headline)

            return cell
        case .valueField:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
            cell.imageView.image = item.image
            cell.isEditable      = false
            cell.titleLabel.text = item.title
            cell.valueLabel.text = item.detail
            cell.placeholderLabel.text = item.placeholder
            return cell
        }
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        let title = viewModel.title(for: section)
        
        if title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            return 0.0
        }
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let item = viewModel.item(at: indexPath)!
        
        var columnCount = item.preferredColumnCount
        if columnCount > 1 {
            columnCount = min(layout.columnCountForSection(withMinimumItemContentWidth: item.minimumContentWidth, sectionEdgeInsets: sectionEdgeInsets), columnCount)
        }
        
        return layout.columnContentWidth(forColumnCount: columnCount, sectionEdgeInsets: sectionEdgeInsets)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let item = viewModel.item(at: indexPath)!
        
        switch item.style {
        case .header, .item:
            let titleFont: UIFont? = item.style == .header ? .systemFont(ofSize: 28.0, weight: UIFontWeightBold) : nil
            let titleSizing = StringSizing(string: item.title ?? "", font: titleFont, numberOfLines: 0)
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: titleSizing, subtitle: item.detail?.ifNotEmpty(), inWidth: itemWidth, compatibleWith: traitCollection, imageSize: item.image?.size ?? .zero) + (item.style == .header ? 15.0 : 0.0)
        case .valueField:
            return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: item.title, value: item.detail ?? item.placeholder, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: item.image?.size ?? .zero)
        }
    }
    
}

extension EventDetailViewController: EntityDetailsViewModelDelegate {
    public func reloadData() {
        collectionView?.reloadData()
    }
}
