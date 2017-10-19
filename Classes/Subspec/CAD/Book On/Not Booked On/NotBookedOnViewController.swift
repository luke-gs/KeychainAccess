//
//  NotBookedOnViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class NotBookedOnViewController: CADFormCollectionViewController<NotBookedOnItemViewModel> {

    /// Layout sizing constants
    public struct LayoutConstants {
        // MARK: - Margins
        static let topMargin: CGFloat = 24
        static let bottomMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 40
        
        // MARK: - Header
        static var headerHeight: CGFloat = 80
        static let footerHeight: CGFloat = 55
        
        // MARK: - Button Padding
        static let verticalButtonPadding: CGFloat = 24
        static let horizontalButtonPadding: CGFloat = 40
        static let edgeButtonPadding: CGFloat = 24
    }
    
    // MARK: - Views
    
    open var titleLabel: UILabel!
    open var stayOffDutyButton: UIButton!
    open var allCallsignsButton: UIButton!
    
    /// `super.viewModel` typecasted to our type
    open var notBookedOnViewModel: NotBookedOnViewModel? {
        return viewModel as? NotBookedOnViewModel
    }
    
    /// Support being transparent when in popover/form sheet
    open override var wantsTransparentBackground: Bool {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
        }
    }
    
    // MARK: - Setup
    
    public init(viewModel: NotBookedOnViewModel) {
        super.init(viewModel: viewModel)
        
        setupViews()
        setupConstraints()
    }
    
    open override func loadView() {
        super.loadView()
        collectionViewTopConstraint?.constant = LayoutConstants.headerHeight
        collectionViewBottomConstraint?.constant = -LayoutConstants.footerHeight
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Creates and styles views
    private func setupViews() {
        let theme = ThemeManager.shared.theme(for: .current)
        let tintColor = theme.color(forKey: .tint)!
        
        edgesForExtendedLayout = []
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = notBookedOnViewModel?.headerText()
        titleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        stayOffDutyButton = UIButton()
        stayOffDutyButton.contentEdgeInsets = UIEdgeInsets(top: LayoutConstants.verticalButtonPadding,
                                                           left: LayoutConstants.edgeButtonPadding,
                                                           bottom: LayoutConstants.verticalButtonPadding,
                                                           right: LayoutConstants.horizontalButtonPadding)
        stayOffDutyButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        stayOffDutyButton.setTitleColor(tintColor, for: .normal)
        stayOffDutyButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        stayOffDutyButton.setTitle(notBookedOnViewModel?.stayOffDutyButtonText(), for: .normal)
        stayOffDutyButton.addTarget(self, action: #selector(didSelectStayOffDutyButton), for: .touchUpInside)
        stayOffDutyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stayOffDutyButton)
        
        allCallsignsButton = UIButton()
        allCallsignsButton.contentEdgeInsets = UIEdgeInsets(top: LayoutConstants.verticalButtonPadding,
                                                            left: LayoutConstants.horizontalButtonPadding,
                                                            bottom: LayoutConstants.verticalButtonPadding,
                                                            right: LayoutConstants.edgeButtonPadding)
        allCallsignsButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        allCallsignsButton.setTitleColor(tintColor, for: .normal)
        allCallsignsButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        allCallsignsButton.setTitle(notBookedOnViewModel?.allCallsignsButtonText(), for: .normal)
        allCallsignsButton.addTarget(self, action: #selector(didSelectAllCallsignsButton), for: .touchUpInside)
        allCallsignsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(allCallsignsButton)
    }
    
    /// Activates view constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutConstants.topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stayOffDutyButton.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            stayOffDutyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            allCallsignsButton.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            allCallsignsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc public func didSelectStayOffDutyButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc public func didSelectAllCallsignsButton() {
        // TODO: Push to all callsigns VC
    }
    
    // MARK: - Override
    
    override open func cellType() -> CollectionViewFormCell.Type {
        return CollectionViewFormSubtitleCell.self
    }
    
    override open func decorate(cell: CollectionViewFormCell, with viewModel: NotBookedOnItemViewModel) {
        cell.highlightStyle = .fade
        cell.selectionStyle = .fade
        cell.separatorStyle = .indented
        cell.separatorColor = UIColor.red
        cell.accessoryView = FormAccessoryView(style: .disclosure)
        
        if let cell = cell as? CollectionViewFormSubtitleCell {
            cell.titleLabel.text = viewModel.title
            cell.subtitleLabel.text = viewModel.subtitle
            cell.imageView.image = viewModel.image?.withRenderingMode(.alwaysTemplate)
            cell.imageView.tintColor = viewModel.imageColor
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let cell = cell as? CollectionViewFormCell {
            cell.separatorColor = iOSStandardSeparatorColor
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        if let header = view as? CollectionViewFormHeaderView {
            header.separatorColor = iOSStandardSeparatorColor
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: present details?
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if let item = viewModel.item(at: indexPath) {
            return CollectionViewFormSubtitleCell.minimumContentWidth(withTitle: item.title, subtitle: item.subtitle, compatibleWith: traitCollection)
        }
        return 0
    }
    
    @objc open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        /// Set first header to have less height as we have too much top padding below the header text
        if section == 0 {
            return 16
        }
        return CollectionViewFormHeaderView.minimumHeight
    }

}
