//
//  PersonDescriptionsViewController.swift
//  Pods
//
//  Created by Gridstone on 6/6/17.
//
//

import UIKit
import MPOLKit

class PersonDescriptionsViewController: FormCollectionViewController {
    open var descriptions: [PersonDescription]? {
        didSet {
            if let descriptions = descriptions {
                viewModel.sections = descriptions
            }
        }
    }
    
    private lazy var viewModel: PersonDescriptionViewModel = {
        var vm = PersonDescriptionViewModel()
        vm.delegate = self
        return vm
    }()
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("More Descriptions", bundle: .mpolKit, comment: "")
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
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
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            view.text = viewModel.year(for: indexPath.section)
            view.showsExpandArrow = true

            view.tapHandler = { [weak self] (headerView, indexPath) in
                guard let `self` = self else { return }
                let section = indexPath.section

                self.viewModel.updateCollapsed(for: [section])
                view.setExpanded(self.viewModel.isExpanded(at: section), animated: true)
                collectionView.reloadSections(IndexSet(integer: section))
            }

            view.isExpanded = viewModel.isExpanded(at: indexPath.section)
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        
        let cellInfo = viewModel.cellInfo(for: indexPath)
        cell.titleLabel.text = cellInfo.title
        cell.valueLabel.text = cellInfo.value
        cell.imageView.image = cellInfo.image
        
        return cell
    }
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        return layout.columnContentWidth(forColumnCount: 1, sectionEdgeInsets: sectionEdgeInsets)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let (title, value) = viewModel.itemForCalculateContentHeight(at: indexPath)
        
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: value, inWidth: itemWidth, compatibleWith: traitCollection)
    }

}

extension PersonDescriptionsViewController: EntityDetailViewModelDelegate {
    public func reloadData() {
        collectionView?.reloadData()
    }
}
