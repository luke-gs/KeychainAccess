//
//  SelectStoppedEntityViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 30/11/17.
//

import UIKit

open class SelectStoppedEntityViewController: CADFormCollectionViewController<SelectStoppedEntityItemViewModel> {
    
    /// Layout sizing constants
    public struct LayoutConstants {
        // MARK: - Height
        static let footerHeight: CGFloat = 64
        
        // MARK: - Button Padding
        static let centerOffsetButton: CGFloat = 3
        static let verticalButtonPadding: CGFloat = 24
        static let horizontalButtonPadding: CGFloat = 40
        static let edgeButtonPadding: CGFloat = 24
    }
    
    // MARK - Views
    
    open var footerDivider: UIView!
    open var searchButton: UIButton!
    
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
        let theme = ThemeManager.shared.theme(for: .current)
        let tintColor = theme.color(forKey: .tint)!
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        footerDivider = UIView()
        footerDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        footerDivider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerDivider)
        
        searchButton = UIButton()
        searchButton.contentEdgeInsets = UIEdgeInsets(top: LayoutConstants.verticalButtonPadding,
                                                      left: LayoutConstants.horizontalButtonPadding,
                                                      bottom: LayoutConstants.verticalButtonPadding - LayoutConstants.centerOffsetButton,
                                                      right: LayoutConstants.edgeButtonPadding)
        searchButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        searchButton.setTitleColor(tintColor, for: .normal)
        searchButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        searchButton.setTitle(selectStoppedEntityViewModel?.searchButtonText(), for: .normal)
        searchButton.addTarget(self, action: #selector(didSelectSearchButton), for: .touchUpInside)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchButton)
    }
    
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            footerDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerDivider.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -LayoutConstants.footerHeight),
            footerDivider.heightAnchor.constraint(equalToConstant: 1),
            
            searchButton.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView?.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            collectionView?.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            collectionView?.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -LayoutConstants.footerHeight).withPriority(.almostRequired)
        ].removeNils())
    }
    
    // MARK: - Actions

    @objc private func didTapCancelButton(_ button: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc open func didSelectSearchButton() {
        // TODO: Present search screen for entities
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
