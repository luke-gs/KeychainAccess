//
//  BookOnLandingViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class BookOnLandingViewController: FormBuilderViewController {

    /// Layout sizing constants
    public struct LayoutConstants {
        // MARK: - Margins
        static let topMargin: CGFloat = 24
        static let bottomMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 40
    }

    // MARK: - Views

    open var titleLabel = UILabel()
    open var buttonsView: DialogActionButtonsView!

    /// `super.viewModel` typecasted to our type
    open var viewModel: BookOnLandingViewModel

    // MARK: - Setup

    public init(viewModel: BookOnLandingViewModel) {
        self.viewModel = viewModel
        super.init()

        title = viewModel.navTitle()
        setupViews()
        setupConstraints()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    /// Creates and styles views
    open func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.text = viewModel.headerText()
        titleLabel.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .primaryText)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        buttonsView = DialogActionButtonsView(actions: [
            DialogAction(title: viewModel.stayOffDutyButtonText(), handler: { [weak self] (_) in
                self?.didSelectStayOffDutyButton()
            }),
            DialogAction(title: viewModel.allCallsignsButtonText(), handler: { [weak self] (_) in
                self?.didSelectAllCallsignsButton()
            })
        ])
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
    }

    /// Activates view constraints
    open func setupConstraints() {
        collectionView?.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView?.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView?.bottomAnchor.constraint(equalTo: buttonsView.topAnchor).withPriority(.almostRequired),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            buttonsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].removeNils())
    }

    open func didSelectStayOffDutyButton() {
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            statusTabBarController?.selectPreviousTab()
        }
    }

    open func didSelectAllCallsignsButton() {
        // Present all callsigns screen
        present(BookOnScreen.callSignList)
    }

    // MARK: - Form Builder
    open override func construct(builder: FormBuilder) {
        let patrolAreaSection = viewModel.patrolAreaSection()

        builder += HeaderFormItem(text: patrolAreaSection.title?.uppercased(),
                                  style: viewModel.shouldShowExpandArrow() ? .collapsible : .plain)

        for item in patrolAreaSection.items {
            builder += ValueFormItem(title: nil, value: item.title, image: item.image)
                .accessory(ItemAccessory.disclosure)
                .width(.column(1))
                .height(.fixed(44))
                .contentMode(.center)
                .onSelection { [weak self] _ in
                    let screen = BookOnScreen.patrolAreaList(current: item.title, delegate: self, formSheet: false)
                    self?.present(screen)
                }
        }

        let callsignSection = viewModel.callsignSection()

        builder += HeaderFormItem(text: callsignSection.title?.uppercased(),
                                  style: viewModel.shouldShowExpandArrow() ? .collapsible : .plain)

        for item in callsignSection.items {
            builder += CustomFormItem(cellType: viewModel.callsignCellClass(),
                                      reuseIdentifier: viewModel.callsignCellClass().defaultReuseIdentifier)
                .accessory(ItemAccessory.disclosure)
                .height(.fixed(64))
                .onConfigured { (cell) in
                    self.viewModel.decorate(cell: cell, with: item)
                }
                .onStyled { (cell) in
                    let theme = ThemeManager.shared.theme(for: self.userInterfaceStyle)
                    self.viewModel.apply(theme: theme, to: cell)
                }
                .onSelection { [weak self] (_) in
                    if let screen = self?.viewModel.bookOnScreenForItem(item) {
                        self?.present(screen)
                    }
                }
        }
    }

    open override func apply(_ theme: Theme) {
        super.apply(theme)

        /// Update label based on theme
        titleLabel.textColor = theme.color(forKey: .primaryText)
    }

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            // Fix padding being wrong at top due to first header being too large
            return 10
        }
        return super.collectionView(collectionView, layout: layout, heightForHeaderInSection: section)
    }
}

extension BookOnLandingViewController: PatrolAreaListViewModelDelegate {

    public func patrolAreaListViewModel(_ viewModel: PatrolAreaListViewModel, didSelectPatrolArea patrolArea: String?) {
        if let patrolArea = patrolArea {
            CADStateManager.shared.patrolGroup = patrolArea
            reloadForm()
        }
    }
}
