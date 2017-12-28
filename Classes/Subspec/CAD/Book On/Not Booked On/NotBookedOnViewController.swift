//
//  NotBookedOnViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class NotBookedOnViewController: FormBuilderViewController {

    /// Layout sizing constants
    public struct LayoutConstants {
        // MARK: - Margins
        static let topMargin: CGFloat = 24
        static let bottomMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 40
        
        // MARK: - Header
        static var headerHeight: CGFloat = 80
        static let footerHeight: CGFloat = 64
        
        // MARK: - Button Padding
        static let centerOffsetButton: CGFloat = 3
        static let verticalButtonPadding: CGFloat = 24
        static let horizontalButtonPadding: CGFloat = 40
        static let edgeButtonPadding: CGFloat = 24
    }
    
    // MARK: - Views
    
    open var footerDivider: UIView!
    open var titleLabel: UILabel!
    open var stayOffDutyButton: UIButton!
    open var allCallsignsButton: UIButton!
    
    /// `super.viewModel` typecasted to our type
    open var viewModel: NotBookedOnViewModel
    
    /// Support being transparent when in popover/form sheet
    open override var wantsTransparentBackground: Bool {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
        }
    }
    
    // MARK: - Setup
    
    public init(viewModel: NotBookedOnViewModel) {
        self.viewModel = viewModel
        super.init()
        
        title = viewModel.navTitle()
        setupViews()
        setupConstraints()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func loadView() {
        super.loadView()
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let collectionView = collectionView {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor, constant: LayoutConstants.headerHeight),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -LayoutConstants.footerHeight).withPriority(.almostRequired)
            ])
        }
    }

    /// Creates and styles views
    open func setupViews() {
        let theme = ThemeManager.shared.theme(for: .current)
        let tintColor = theme.color(forKey: .tint)!
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = viewModel.headerText()
        titleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        stayOffDutyButton = UIButton()
        stayOffDutyButton.contentEdgeInsets = UIEdgeInsets(top: LayoutConstants.verticalButtonPadding,
                                                           left: LayoutConstants.edgeButtonPadding,
                                                           bottom: LayoutConstants.verticalButtonPadding - LayoutConstants.centerOffsetButton,
                                                           right: LayoutConstants.horizontalButtonPadding)
        stayOffDutyButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        stayOffDutyButton.setTitleColor(tintColor, for: .normal)
        stayOffDutyButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        stayOffDutyButton.setTitle(viewModel.stayOffDutyButtonText(), for: .normal)
        stayOffDutyButton.addTarget(self, action: #selector(didSelectStayOffDutyButton), for: .touchUpInside)
        stayOffDutyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stayOffDutyButton)
        
        allCallsignsButton = UIButton()
        allCallsignsButton.contentEdgeInsets = UIEdgeInsets(top: LayoutConstants.verticalButtonPadding,
                                                            left: LayoutConstants.horizontalButtonPadding,
                                                            bottom: LayoutConstants.verticalButtonPadding - LayoutConstants.centerOffsetButton,
                                                            right: LayoutConstants.edgeButtonPadding)
        allCallsignsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        allCallsignsButton.setTitleColor(tintColor, for: .normal)
        allCallsignsButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        allCallsignsButton.setTitle(viewModel.allCallsignsButtonText(), for: .normal)
        allCallsignsButton.addTarget(self, action: #selector(didSelectAllCallsignsButton), for: .touchUpInside)
        allCallsignsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(allCallsignsButton)
        
        footerDivider = UIView()
        footerDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        footerDivider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerDivider)
    }
    
    /// Activates view constraints
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutConstants.topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            footerDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerDivider.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -LayoutConstants.footerHeight),
            footerDivider.heightAnchor.constraint(equalToConstant: 1),
            
            stayOffDutyButton.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            stayOffDutyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            allCallsignsButton.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            allCallsignsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    @objc open func didSelectStayOffDutyButton() {
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            statusTabBarController?.selectPreviousTab()
        }
    }
    
    @objc open func didSelectAllCallsignsButton() {
        // TODO: Push to all callsigns VC
        self.navigationController?.pushViewController(CallsignListViewModel().createViewController(), animated: true)
    }
    
    // MARK: - Form Builder
    open override func construct(builder: FormBuilder) {
        let patrolAreaSection = viewModel.patrolAreaSection()

        builder += HeaderFormItem(text: patrolAreaSection.title.uppercased(),
                                  style: viewModel.shouldShowExpandArrow() ? .collapsible : .plain)

        for item in patrolAreaSection.items {
            builder += ValueFormItem(title: nil, value: item.title, image: item.image)
                .accessory(ItemAccessory.disclosure)
                .width(.column(1))
                .height(.fixed(44))
                .onThemeChanged({ (cell, theme) in
                    (cell as? CollectionViewFormValueFieldCell)?.valueLabel.textColor = theme.color(forKey: .primaryText)
                })
                .contentMode(.center)
                .onSelection({ [weak self] _ in
                    let viewModel = PatrolAreaListViewModel()
                    viewModel.selectedPatrolArea = item.title
                    self?.navigationController?.pushViewController(viewModel.createViewController(), animated: true)
                })
        }
        
        let callsignSection = viewModel.callsignSection()

        builder += HeaderFormItem(text: callsignSection.title.uppercased(),
                                  style: viewModel.shouldShowExpandArrow() ? .collapsible : .plain)

        for item in callsignSection.items {
            builder += CustomFormItem(cellType: CallsignCollectionViewCell.self,
                                      reuseIdentifier: CallsignCollectionViewCell.defaultReuseIdentifier)
                .accessory(ItemAccessory.disclosure)
                .height(.fixed(64))
                .onConfigured({ (cell) in
                    (cell as? CallsignCollectionViewCell)?.decorate(with: item)
                })
                .onThemeChanged({ (cell, theme) in
                    (cell as? CallsignCollectionViewCell)?.apply(theme: theme)
                })
                .onSelection({ [weak self] (cell) in
                    if let viewController = self?.viewModel.bookOnViewControllerForItem(item) {
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                })
        }
    }
    
}
