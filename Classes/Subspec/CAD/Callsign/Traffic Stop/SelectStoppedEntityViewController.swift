//
//  SelectStoppedEntityViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import UIKit

open class SelectStoppedEntityViewController: CADFormCollectionViewController<SelectStoppedEntityItemViewModel> {
    
    // MARK - Views
    
    open var buttonsView: DialogActionButtonsView!

    /// `super.viewModel` typecasted to our type
    open var selectStoppedEntityViewModel: SelectStoppedEntityViewModel? {
        return viewModel as? SelectStoppedEntityViewModel
    }
    
    // MARK: - Setup
    
    public init(viewModel: SelectStoppedEntityViewModel) {
        super.init(viewModel: viewModel)
        
        setupViews()
        setupConstraints()
        setupNavigationBarButtons()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open func setupNavigationBarButtons() {
        // Create cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton(_:)))
    }
    
    open func setupViews() {
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView = DialogActionButtonsView(actions: [
            DialogAction(title: selectStoppedEntityViewModel?.searchButtonText() ?? "", handler: { [weak self] (action) in
                self?.didSelectSearchButton()
            })
        ])
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
    }
    
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),

            collectionView?.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            collectionView?.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            collectionView?.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -DialogActionButtonsView.LayoutConstants.defaultHeight).withPriority(.almostRequired)
        ].removeNils())
    }
    
    // MARK: - Actions

    @objc private func didTapCancelButton(_ button: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc open func didSelectSearchButton() {
        // Present search screen for entities
        Director.shared.present(BookOnScreen.trafficStopSearchEntity, fromViewController: self)
    }
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        return EntityListCollectionViewCell.self
    }
    
    open override func decorate(cell: CollectionViewFormCell, with viewModel: SelectStoppedEntityItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        
        if let cell = cell as? EntityListCollectionViewCell {
            cell.sourceLabel.text = viewModel.category
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.thumbnailView.borderColor = viewModel.borderColor
            cell.thumbnailView.tintColor = viewModel.imageColor ?? .primaryGray
            cell.thumbnailView.imageView.image = viewModel.image
            cell.thumbnailView.imageView.contentMode = .center
            
            cell.sourceLabel.textColor = secondaryTextColor
            cell.sourceLabel.borderColor = secondaryTextColor
            cell.sourceLabel.backgroundColor = .clear
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectStoppedEntityViewModel?.didSelectItem(at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        return EntityListCollectionViewCell.minimumContentHeight(withTitle: nil, subtitle: nil, source: nil, inWidth: itemWidth, compatibleWith: traitCollection)
    }
    
    @objc open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }

}
